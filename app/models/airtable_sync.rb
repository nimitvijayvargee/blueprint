# == Schema Information
#
# Table name: airtable_syncs
#
#  id                     :bigint           not null, primary key
#  last_synced_at         :datetime
#  record_identifier      :string           not null
#  synced_attributes_hash :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  airtable_id            :string
#
# Indexes
#
#  index_airtable_syncs_on_record_identifier  (record_identifier) UNIQUE
#
require "csv"

class AirtableSync < ApplicationRecord
  def self.needs_sync?(record)
    identifier = build_identifier(record)
    sync_record = find_by(record_identifier: identifier)
    return true unless sync_record

    record.updated_at > sync_record.last_synced_at
  end

  def self.mark_synced(record, airtable_id)
    identifier = build_identifier(record)
    sync_record = find_or_initialize_by(record_identifier: identifier)
    sync_record.update!(
      airtable_id: airtable_id,
      last_synced_at: Time.current
    )
  end

  def self.sync!(classname, limit: nil, sync_all: false)
    batch = false
    klass = resolve_class(classname)
    validate_sync_methods!(klass)

    table_id = klass.airtable_sync_table_id
    field_mappings = klass.airtable_sync_field_mappings
    has_sync_id = klass.respond_to?(:airtable_sync_sync_id)

    batch = true if has_sync_id

    records = batch || sync_all ? all_records(klass, limit) : outdated_records(klass, limit)

    airtable_ids = []

    if batch
      batch_sync!(table_id, records, klass.airtable_sync_sync_id, field_mappings)
    else
      records.each do |record|
        old_airtable_id = find_by(record_identifier: build_identifier(record))&.airtable_id
        airtable_ids << individual_sync!(table_id, record, field_mappings, old_airtable_id)
      end
    end

    sync_data = records.map do |record|
      data = {
        record_identifier: build_identifier(record),
        last_synced_at: Time.current,
        created_at: Time.current,
        updated_at: Time.current
      }
      if !batch
        data[:airtable_id] = airtable_ids.shift
      end
      data
    end

    upsert_all(sync_data, unique_by: :record_identifier) if sync_data.any?

    records
  end

  def self.batch_sync!(table_id, records, sync_id, mappings)
    csv_string = CSV.generate do |csv|
      csv << mappings.keys

      records.each do |record|
        fields = build_airtable_fields(record, mappings)
        csv << fields.values
      end
    end

    response = Faraday.post("https://api.airtable.com/v0/#{ENV['AIRTABLE_BASE_ID']}/#{table_id}/sync/#{sync_id}") do |req|
      req.headers = {
        "Authorization" => "Bearer #{ENV['AIRTABLE_PAT']}",
        "Content-Type" => "text/csv"
      }
      req.body = csv_string
    end

    Rails.logger.info("Airtable batch sync response: #{response.status} - #{response.body}")
    if response.status < 200 || response.status >= 300
      raise "Airtable batch sync failed with status #{response.status}: #{response.body}"
    end
  end

  def self.individual_sync!(table_id, record, mappings, old_airtable_id)
    fields = build_airtable_fields(record, mappings)
    upload_or_create!(table_id, record, fields)
  end

  def self.upload_or_create!(table_id, object, fields)
    old_airtable_id = find_by(record_identifier: build_identifier(object))&.airtable_id

    if old_airtable_id.present?
      method = :patch
      url = "https://api.airtable.com/v0/#{ENV['AIRTABLE_BASE_ID']}/#{table_id}/#{old_airtable_id}"
    else
      method = :post
      url = "https://api.airtable.com/v0/#{ENV['AIRTABLE_BASE_ID']}/#{table_id}"
    end

    response = Faraday.send(method, url) do |req|
      req.headers = {
        "Authorization" => "Bearer #{ENV['AIRTABLE_PAT']}",
        "Content-Type" => "application/json"
      }
      req.body = { fields: fields, typecast: true }.to_json
    end

    Rails.logger.info("Airtable individual sync response: #{response.status} - #{response.body}")
    if response.status < 200 || response.status >= 300
      raise "Airtable individual sync failed with status #{response.status}: #{response.body}"
    end

    JSON.parse(response.body)["id"]
  end

  private

  def self.resolve_class(classname)
    classname.is_a?(String) ? classname.constantize : classname
  end

  def self.validate_sync_methods!(klass)
    unless klass.respond_to?(:airtable_sync_table_id)
      raise "#{klass.name} must implement airtable_sync_table_id class method"
    end

    unless klass.respond_to?(:airtable_sync_field_mappings)
      raise "#{klass.name} must implement airtable_sync_field_mappings class method"
    end
  end

  def self.all_records(klass, limit)
    query = klass.all
    query = query.limit(limit) if limit.present?
    query.to_a
  end

  def self.outdated_records(klass, limit)
    table_name = klass.table_name

    join_sql = sanitize_sql_array([
      "LEFT JOIN airtable_syncs ON airtable_syncs.record_identifier = CONCAT(?, '#', #{table_name}.id::text)",
      klass.name
    ])

    where_sql = "airtable_syncs.id IS NULL OR #{table_name}.updated_at > airtable_syncs.last_synced_at"

    records_query = klass.joins(join_sql).where(where_sql)
    records_query = records_query.limit(limit) if limit.present?
    records_query.to_a
  end

  def self.build_airtable_fields(record, field_mappings)
    field_mappings.transform_values do |mapping|
      if mapping.is_a?(Proc)
        mapping.call(record)
      else
        record.send(mapping)
      end
    end
  end

  def self.build_identifier(record)
    "#{record.class.name}##{record.id}"
  end
end
