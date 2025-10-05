# Backfill ahoy_visits.user_id from ahoy_events.user_id
# Usage:
#   bin/rails ahoy:backfill_visits DRY_RUN=true LIMIT=100 BATCH_SIZE=1000 VERBOSE=true
namespace :ahoy do
  desc "Backfill ahoy_visits.user_id from ahoy_events.user_id."
  task backfill_visits: :environment do
    dry_run = ENV["DRY_RUN"].to_s.downcase == "true" || ENV["DRY_RUN"].to_s == "1"
    batch_size = (ENV["BATCH_SIZE"] || 1000).to_i
    limit = (ENV["LIMIT"] || 0).to_i
    verbose = ENV["VERBOSE"].to_s.downcase == "true" || ENV["VERBOSE"].to_s == "1"

  puts "Starting ahoy_visits backfill - dry_run=#{dry_run}, batch_size=#{batch_size}, limit=#{limit}, verbose=#{verbose}"

    visit_scope = Ahoy::Visit.where(user_id: nil)
    visit_scope = visit_scope.limit(limit) if limit > 0

  total = visit_scope.count
  puts "Found #{total} visits with nil user_id to process (limit=#{limit})" if verbose || dry_run

    processed = 0

    visit_scope.find_in_batches(batch_size: batch_size) do |visits_batch|
      visit_ids = visits_batch.map(&:id)

  # Find events that have a user_id and belong to these visits. Order to pick a deterministic user_id.
  events = Ahoy::Event.where(visit_id: visit_ids).where.not(user_id: nil).order(:id).select(:visit_id, :user_id)

      # Map visit_id => user_id (pick the first non-nil user_id per visit)
      visit_user_map = {}
      events.each do |e|
        visit_user_map[e.visit_id] ||= e.user_id
      end

      updates = []
      visit_ids.each do |vid|
        if visit_user_map[vid]
          updates << [ vid, visit_user_map[vid] ]
        end
      end

      if updates.empty?
        puts "Batch: no visits to update" if verbose
      else
        puts "Batch: preparing to update #{updates.size} visits" if verbose

        if dry_run
          updates.first(10).each do |vid, uid|
            puts "DRY RUN - would set visit_id=#{vid} user_id=#{uid}"
          end
        else
          # Perform updates in a single SQL statement per visit to avoid callbacks
          updated_in_batch = 0
          Ahoy::Visit.transaction do
            updates.each do |vid, uid|
              # Only update if visit still has nil user_id to avoid overwriting concurrent updates
              affected = Ahoy::Visit.where(id: vid, user_id: nil).update_all(user_id: uid)
              updated_in_batch += affected
            end
          end
          puts "Updated #{updated_in_batch} visits in this batch" if verbose
        end
      end

      processed += visits_batch.size
      break if limit > 0 && processed >= limit
    end

    puts "Done. Processed #{processed} visits (dry_run=#{dry_run})"
  end
end
