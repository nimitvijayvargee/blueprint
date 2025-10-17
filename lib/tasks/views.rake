namespace :views do
  desc "Backfill project_user_views from ahoy_events"
  task backfill: :environment do
    batch_size = ENV.fetch("BATCH_SIZE", 100_000).to_i

    min_id = Ahoy::Event.where(name: "project_view").minimum(:id)
    max_id = Ahoy::Event.where(name: "project_view").maximum(:id)

    if min_id.nil? || max_id.nil?
      puts "No project_view events found in ahoy_events"
      next
    end

    puts "Backfilling from ahoy_events id #{min_id}..#{max_id}"
    puts "Batch size: #{batch_size}"

    (min_id..max_id).step(batch_size) do |start_id|
      end_id = [ start_id + batch_size - 1, max_id ].min

      sql = <<~SQL
        INSERT INTO project_user_views (project_id, user_id, first_viewed_at)
        SELECT#{' '}
          p.id AS project_id,
          u.id AS user_id,
          MIN(e.time) AS first_viewed_at
        FROM ahoy_events e
        JOIN projects p ON p.id = (e.properties->>'project_id')::bigint
        JOIN users u ON u.id = (e.properties->>'user_id')::bigint
        WHERE e.name = 'project_view'
          AND e.id BETWEEN #{start_id} AND #{end_id}
          AND (e.properties->>'user_id') ~ '^[0-9]+$'
          AND (e.properties->>'project_id') ~ '^[0-9]+$'
        GROUP BY p.id, u.id
        ON CONFLICT (project_id, user_id) DO UPDATE
          SET first_viewed_at = LEAST(EXCLUDED.first_viewed_at, project_user_views.first_viewed_at);
      SQL

      ActiveRecord::Base.connection.execute(sql)
      puts "Processed #{start_id}-#{end_id}"
    end

    puts "\nBackfill complete. Recomputing project views_count..."

    # Recompute counters after backfill (including zeros)
    sql = <<~SQL
      UPDATE projects p
      SET views_count = COALESCE(sub.ct, 0)
      FROM (
        SELECT p2.id AS project_id, puv.ct
        FROM projects p2
        LEFT JOIN (
          SELECT project_id, COUNT(*)::integer AS ct
          FROM project_user_views
          GROUP BY project_id
        ) puv ON puv.project_id = p2.id
      ) sub
      WHERE p.id = sub.project_id;
    SQL

    ActiveRecord::Base.connection.execute(sql)
    puts "Done! Projects views_count updated."
  end

  desc "Reconcile project views_count from project_user_views (use to fix drift)"
  task reconcile: :environment do
    puts "Reconciling project views_count from project_user_views..."

    sql = <<~SQL
      UPDATE projects p
      SET views_count = COALESCE(sub.ct, 0)
      FROM (
        SELECT p2.id AS project_id, puv.ct
        FROM projects p2
        LEFT JOIN (
          SELECT project_id, COUNT(*)::integer AS ct
          FROM project_user_views
          GROUP BY project_id
        ) puv ON puv.project_id = p2.id
      ) sub
      WHERE p.id = sub.project_id;
    SQL

    result = ActiveRecord::Base.connection.execute(sql)
    puts "Done! Updated #{result.cmd_tuples} projects."
  end
end
