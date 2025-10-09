class RecommenderJob < ApplicationJob
  queue_as :recommendation

  def perform
    journal_recommender = Disco::Recommender.new(top_items: true)
    project_recommender = Disco::Recommender.new(top_items: true)

    all_journal_views = Ahoy::Event.where(name: [ "journal_entry_view" ])
      .where.not(user_id: nil)
      .joins("INNER JOIN projects ON (properties->>'project_id')::integer = projects.id")
      .where(projects: { is_deleted: false })
      .group(:user_id)
      .group_prop(:journal_entry_id)
      .count

    all_project_views = Ahoy::Event.where(name: [ "project_view", "journal_entry_view" ])
      .where.not(user_id: nil)
      .joins("INNER JOIN projects ON (properties->>'project_id')::integer = projects.id")
      .where(projects: { is_deleted: false })
      .group(:user_id)
      .group_prop(:project_id)
      .count

    journal_data = all_journal_views.flat_map do |(user_id, journal_entry_id), count|
      Array.new(count) { { user_id: user_id, item_id: journal_entry_id } }
    end

    project_data = all_project_views.flat_map do |(user_id, project_id), count|
      Array.new(count) { { user_id: user_id, item_id: project_id } }
    end

    journal_recommender.fit(journal_data)
    project_recommender.fit(project_data)

    journal_entry_count = Project.joins(:journal_entries)
        .where(is_deleted: false)
        .distinct
        .count("journal_entries.id")
    project_count = Project.where(is_deleted: false).count

    top_journal_recs = journal_recommender.top_items(count: [ 1000, journal_entry_count ].min)
    top_project_recs = project_recommender.top_items(count: [ 1000, project_count ].min)
    StoredRecommendation.find_or_create_by(key: "top_journal_entries").update(data: top_journal_recs)
    StoredRecommendation.find_or_create_by(key: "top_project_entries").update(data: top_project_recs)

    require "concurrent"

    pool = Concurrent::FixedThreadPool.new(10)

    User.find_each do |user|
        # pool.post do
        journal_recs = journal_recommender.user_recs(user.id, count: [ 1000, journal_entry_count ].min)
        journal_recs = top_journal_recs if journal_recs.empty?
        user.update_recommended_journal_entries(journal_recs)

        project_recs = project_recommender.user_recs(user.id, count: [ 1000, project_count ].min)
        project_recs = top_project_recs if project_recs.empty?
        user.update_recommended_projects(project_recs)
      # end
    end

    pool.shutdown
    pool.wait_for_termination
  end
end
