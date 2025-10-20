require_relative "../config/environment"
require "csv"

EDT = ActiveSupport::TimeZone["America/New_York"]

last_sunday = EDT.now.beginning_of_week(:sunday) - 1.week
this_sunday = last_sunday + 1.week

start_date = last_sunday.end_of_day
end_date = this_sunday.end_of_day

puts "Counting valid referrals between:"
puts "Start: #{start_date.strftime('%Y-%m-%d %H:%M:%S %Z')}"
puts "End:   #{end_date.strftime('%Y-%m-%d %H:%M:%S %Z')}"
puts "\nPress Enter to continue or type new dates (format: YYYY-MM-DD YYYY-MM-DD):"

input = gets.chomp
unless input.empty?
  dates = input.split
  start_date = EDT.parse(dates[0]).beginning_of_day
  end_date = EDT.parse(dates[1]).end_of_day
  puts "Using custom range: #{start_date} to #{end_date}"
end

referrals = User.where(created_at: start_date..end_date)
                .where.not(slack_id: nil)
                .where(is_mcg: false)
                .where.not(referrer_id: nil)
                .group(:referrer_id)
                .count

puts "\n=== Valid Referral Counts ==="
sorted_referrals = referrals.sort_by { |_, count| -count }

sorted_referrals.each do |referrer_id, count|
  referrer = User.find(referrer_id)
  puts "#{referrer.username || referrer.email} (ID: #{referrer_id}): #{count} valid referrals"
end

puts "\nTotal valid referrals: #{referrals.values.sum}"

filename = "valid_referrals_#{start_date.strftime('%Y%m%d')}_to_#{end_date.strftime('%Y%m%d')}.csv"
CSV.open(filename, "w") do |csv|
  csv << [ "Referrer ID", "Username", "Email", "Slack ID", "Valid Referral Count" ]
  sorted_referrals.each do |referrer_id, count|
    referrer = User.find(referrer_id)
    csv << [ referrer_id, referrer.username, referrer.email, referrer.slack_id, count ]
  end
end

puts "\nSaved to #{filename}"
