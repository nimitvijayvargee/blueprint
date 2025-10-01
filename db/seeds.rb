# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Sample projects for the homepage
sample_projects = [
  {
    title: "Serenity",
    repo_link: "https://github.com/The-UnknownHacker/Serenity",
    description: "Serenity is a drumpad or macropad designed with musicians in mind. Instead of using traditional switches or buttons, it uses a copper layer on the PCB to detect touch input. Powered by an ESP32-S3 devkit, Serenity can store sound files on a microSD card and output audio through a headphone jack. It features 2 configurable buttons that let you switch between sound layers — allowing you to play many more sounds than just 8. For example, with 4 layers, you can trigger 32 unique sounds.",
    github_username: "The-UnknownHacker"
  },
  {
    title: "CyberTrust",
    repo_link: "https://github.com/Aahil78/CyberTrust",
    description: "This is a simple RP2350A based USB Security Key that has a user presence button and a neopixel. I made it all in KiCad.",
    github_username: "Aahil78"
  },
  {
    title: "Nexo-BT",
    repo_link: "https://github.com/Arrow-07/NexoBT",
    description: "I started this project for HIGHWAY but i didn't finish in time. Nexo-Bt is a wireless receiver for music with balanced audio outputs with XLR connectors. It use: an ESP32, a DAC: PCM5102APWR, 2 differential DRIVER: DRV135UA/2K5",
    github_username: "Arrow-07"
  },
  {
    title: "KeyDeck",
    repo_link: "https://github.com/CJBrandi/KeyDeck/",
    description: "A simple macropad made using the hackpad tutorial and cadded in onshape. 2 leds for status. every button runs different shortcut.",
    github_username: "CJBrandi"
  },
  {
    title: "bop",
    repo_link: "https://github.com/ShuchirJ/bop",
    description: "A bluetooth audio receiver to line level and headphone level out.",
    github_username: "ShuchirJ"
  },
  {
    title: "Fulmen",
    repo_link: "https://github.com/AethelVeritas/Fulmen/tree/main",
    description: "Fulmen is a small ergonomic low-profile wireless keyboard. It's also reversible :).",
    github_username: "AethelVeritas"
  },
  {
    title: "BIcolor Matrix Board",
    repo_link: "https://github.com/picafe/bicolor-matrix",
    description: "Red and Green 32x8 LED Matrix with HT16K33A IC",
    github_username: "picafe"
  },
  {
    title: "Quaero",
    repo_link: "https://github.com/AethelVeritas/Quaero/tree/main",
    description: "A low-profile split ergo keyboard, featuring splay, a removable column and number row, as well as potential trackpad support.",
    github_username: "AethelVeritas"
  }
]

# Create a demo user if it doesn't exist
demo_user = User.find_or_create_by!(email: "demo@hackclub.com") do |user|
  user.slack_id = "DEMO123"
  user.github_username = "demo-user"
end

# Create sample projects for the demo user
sample_projects.each do |project_data|
  Project.find_or_create_by!(
    title: project_data[:title],
    user: demo_user
  ) do |project|
    project.repo_link = project_data[:repo_link]
    project.description = project_data[:description]
    project.project_type = "pcb"
    project.tier = 2
  end
end
