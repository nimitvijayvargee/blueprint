class LandingController < ApplicationController
  allow_unauthenticated_access only: %i[index authed]
  before_action :set_featured_projects

  def index
    if user_logged_in?
      redirect_to home_path
      return
    end

    ahoy.track "landing_visit"

    render layout: false
  end

  def authed
    redirect_to root_path and return unless user_logged_in?

    render "landing/index", layout: false
  end

  private

  def set_featured_projects
    @featured_projects = [
        {
          title: "Serenity",
          url: "https://github.com/The-UnknownHacker/Serenity",
          image: "https://hc-cdn.hel1.your-objectstorage.com/s/v3/83cea4e7008db1f618e6f33b12a19d25924259c9_image.png",
          description: "Touch-based drumpad with ESP32-S3, copper PCB sensing, microSD storage, and configurable sound layers",
          author: "The-UnknownHacker"
        },
        {
          title: "CyberTrust",
          url: "https://github.com/Aahil78/CyberTrust",
          image: "https://hc-cdn.hel1.your-objectstorage.com/s/v3/625db8d60acaa7cdf3406308dedd19f21e35954f_image.png",
          description: "RP2350A-based USB security key with user presence button and neopixel",
          author: "Aahil78"
        },
        {
          title: "Nexo-BT",
          url: "https://github.com/Arrow-07/NexoBT",
          image: "https://hc-cdn.hel1.your-objectstorage.com/s/v3/aaaa4a0cdd5f4ae02713865f04ad86aa1edd7bcb_image.png",
          description: "Wireless music receiver with balanced XLR outputs using ESP32 and PCM5102APWR DAC",
          author: "Arrow-07"
        },
        {
          title: "KeyDeck",
          url: "https://github.com/CJBrandi/KeyDeck/",
          image: "https://hc-cdn.hel1.your-objectstorage.com/s/v3/98560ad52d04e91c453043c0c68692ae78a5f209_image.png",
          description: "Simple macropad with 2 status LEDs, each button runs a different shortcut",
          author: "CJBrandi"
        },
        {
          title: "bop",
          url: "https://github.com/ShuchirJ/bop",
          image: "https://raw.githubusercontent.com/ShuchirJ/bop/main/render.png",
          description: "Bluetooth audio receiver with line level and headphone level outputs",
          author: "ShuchirJ"
        },
        {
          title: "Fulmen",
          url: "https://github.com/AethelVeritas/Fulmen/tree/main",
          image: "https://hc-cdn.hel1.your-objectstorage.com/s/v3/826c1fc2c73606fe19d470a00726393d26af5777_image.png",
          description: "Small ergonomic low-profile wireless keyboard, reversible design",
          author: "AethelVeritas"
        },
        {
          title: "Bicolor Matrix Board",
          url: "https://github.com/picafe/bicolor-matrix",
          image: "https://raw.githubusercontent.com/picafe/bicolor-matrix/main/assets/kicad_k9HAfz9kqA.png",
          description: "Red and green 32x8 LED matrix with HT16K33A IC",
          author: "picafe"
        },
        {
          title: "Quaero",
          url: "https://github.com/AethelVeritas/Quaero/tree/main",
          image: "https://raw.githubusercontent.com/AethelVeritas/Quaero/refs/heads/main/pics/pic_16.png",
          description: "Low-profile split ergo keyboard with splay, removable column/number row, and trackpad support",
          author: "AethelVeritas"
        },
        {
          title: "WASP",
          url: "https://github.com/justhar/WASP-OPSI",
          image: "https://raw.githubusercontent.com/justhar/WASP-OPSI/main/WASP.png",
          description: "Wi-Fi sensing platform with 8 synchronized ESP32 nodes for AoA, localization, and gesture recognition",
          author: "justhar"
        },
        {
          title: "Athena",
          url: "https://github.com/NotARoomba/Athena",
          image: "https://raw.githubusercontent.com/NotARoomba/Athena/main/assets/board_front.png",
          description: "Advanced flight controller with triple MCU architecture",
          author: "NotARoomba"
        },
        {
          title: "wake",
          url: "https://github.com/JavaScythe/wake/",
          image: "https://hc-cdn.hel1.your-objectstorage.com/s/v3/9fa7d0bf0d3d7f7041138a8fbcee0b6e9a18b987_image.png",
          description: "Advanced alarm clock with 35 neopixels, ESP32 wifi, speaker, buzzer, and projector",
          author: "JavaScythe"
        },
        {
          title: "Automatic Toilet Paper Folder V2",
          url: "https://github.com/Synaptic-Odyssey/AutomaticToiletPaperFolder_V2",
          image: "https://raw.githubusercontent.com/Synaptic-Odyssey/AutomaticToiletPaperFolder_V2/refs/heads/main/Images/ATPF_poster.png",
          description: "Streamlined product version of the 1st place Highway to Undercity project",
          author: "Synaptic-Odyssey"
        },
        {
          title: "PR Mini Bot",
          url: "https://github.com/tobycm/pr-mini-bot",
          image: "https://raw.githubusercontent.com/tobycm/pr-mini-bot/refs/heads/main/images/3d.png",
          description: "Miniature bot mimicking 8339 2025 FRC bot with solar panel and supercaps for power harvesting",
          author: "tobycm"
        },
        {
          title: "VikramSatv0 Electrical Power Sub-system",
          url: "https://github.com/Rishaan2202/VikramSat_Electrical-Power-Sub-System",
          image: "https://hc-cdn.hel1.your-objectstorage.com/s/v3/8a126694bd272e8df76d3cdfee6883ce0abde398_image.png",
          description: "Fully functional EPS for 2U CubeSat project by 14-year-old maker",
          author: "Rishaan2202"
        }
      ]
  end
end
