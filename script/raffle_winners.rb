require "csv"
require "securerandom"

puts "Enter CSV filename:"
filename = gets.chomp

unless File.exist?(filename)
  puts "Error: File not found"
  exit 1
end

tickets = []
referrers = {}

CSV.foreach(filename, headers: true) do |row|
  referrer_id = row["Referrer ID"].to_i
  username = row["Username"]
  email = row["Email"]
  count = row["Valid Referral Count"].to_i
  slack_id = row["Slack ID"]

  referrers[referrer_id] = { username: username, email: email, slack_id: slack_id, count: count }

  count.times { tickets << referrer_id }
end

puts "\nTotal tickets in pool: #{tickets.size}"
puts "Total participants: #{referrers.size}"

puts "\nHow many winners to draw?"
n = gets.chomp.to_i

if n > referrers.size
  puts "Error: Cannot draw more winners than participants"
  exit 1
end

winners = []
remaining_tickets = tickets.shuffle(random: Random.new(SecureRandom.random_number(2**64)))

n.times do
  winner_id = remaining_tickets.shift
  winners << winner_id
  remaining_tickets.reject! { |id| id == winner_id }
end

puts "\n=== RAFFLE WINNERS ==="
winners.each_with_index do |winner_id, index|
  referrer = referrers[winner_id]
  puts "#{index + 1}. #{referrer[:username] || referrer[:email]} (Slack: #{referrer[:slack_id]}) - had #{referrer[:count]} tickets"
end
