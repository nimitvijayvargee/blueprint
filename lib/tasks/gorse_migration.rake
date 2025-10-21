namespace :gorse do
  namespace :migrate_prefixed_ids do
    desc "Backfill all items and feedback to Gorse with prefixed IDs using bulk sync"
    task all: :environment do
      puts "Starting full Gorse migration with prefixed IDs..."
      puts "This will sync users, items (projects + journal entries), and feedback"
      
      GorseSyncJob.perform_now
      
      puts "\nMigration complete!"
    end

  end

  desc "Cleanup legacy Gorse items (numeric IDs)"
  task cleanup_legacy_items: :environment do
    puts "Starting cleanup of legacy Gorse items..."
    puts "WARNING: This will delete all legacy numeric project IDs from Gorse"
    puts "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
    sleep 5

    count = 0
    Project.find_each do |project|
      begin
        GorseService.delete_item_by_id(project.id.to_s)
        count += 1
        print "\rDeleted: #{count}" if count % 10 == 0
      rescue => e
        puts "\nFailed to delete legacy item #{project.id}: #{e.message}"
      end
    end

    puts "\n\nCleanup complete!"
    puts "Legacy items deleted: #{count}"
  end
end
