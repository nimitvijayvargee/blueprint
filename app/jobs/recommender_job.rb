class RecommenderJob < ApplicationJob
  queue_as :recommendation

  def perform
    recommender = Disco::Recommender.new(top_items: true)

    all_views = Ahoy::Event.where(name: [ "journal_entry_view" ])
      .where.not(user_id: nil)
      .joins("INNER JOIN projects ON (properties->>'project_id')::integer = projects.id")
      .where(projects: { is_deleted: false })
      .group(:user_id)
      .group_prop(:journal_entry_id)
      .count

    data = all_views.flat_map do |(user_id, journal_entry_id), count|
      Array.new(count) { { user_id: user_id, item_id: journal_entry_id } }
    end

    recommender.fit(data)

    journal_entry_count = Project.joins(:journal_entries)
        .where(is_deleted: false)
        .distinct
        .count("journal_entries.id")

    top_recs = recommender.top_items(count: [ 1000, journal_entry_count ].min)

    # require "concurrent"

    # pool = Concurrent::FixedThreadPool.new(20)

    User.find_each do |user|
        # pool.post do
        recs = recommender.user_recs(user.id, count: [ 1000, journal_entry_count ].min)
        recs = top_recs if recs.empty?
        user.update_recommended_journal_entries(recs)
      # end
    end

    # pool.shutdown
    # pool.wait_for_termination

    recommender
  end
end
