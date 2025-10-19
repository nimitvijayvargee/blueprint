class ToolbagController < ApplicationController
  def index
    @items = [
      {
        "name" => "Wire strippers",
        "description" => "A 7-inch wire stripper with a built-in cutter for cleanly removing insulation from electrical wires.",
        "price_tickets" => 50,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/120a2b49e3c4643098af61193ac3dd679c97f9bb_98410_W3_1.png"
      },
      {
        "name" => "Flush Cutters",
        "description" => "Compact micro flush cutters ideal for trimming wire ends and plastic parts with precision.",
        "price_tickets" => 50,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/f256bf7bd8f2b3a56eb23efa9ee74299168a8052_90708_W3_1.png"
      },
      {
        "name" => "Needle-nose pliers",
        "description" => "Slim 5-3/4 inch pliers for gripping, bending, and manipulating small wires or components.",
        "price_tickets" => 50,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/3bad26a016feed17caebe59cd998b534adfd1c30_63815_I_1.png"
      },
      {
        "name" => "Precision screwdrivers",
        "description" => "A 33-piece precision screwdriver set for small electronics and detailed mechanical work.",
        "price_tickets" => 70,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/48beb32ad11eacd129987052573014c8c9f5fc7d_image_23444_1.png"
      },
      {
        "name" => "Safety Glasses",
        "description" => "Clear protective eyewear designed to shield eyes from solder splashes and debris.",
        "price_tickets" => 40,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/4a0d1c2fff8c50485faa4640741e55359e4d50e2_99762_W3_1.png"
      },
      {
        "name" => "Digital multimeter",
        "description" => "A 7-function multimeter for measuring voltage, current, and resistance in circuits.",
        "price_tickets" => 60,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/55f19a4d74c0b8d4450db2d547fe88ce8447dd33_59434_W3_1.png"
      },
      {
        "name" => "Soldering Iron",
        "description" => "A lightweight 30W soldering iron perfect for electronics assembly and repair work.",
        "price_tickets" => 70,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/45c11e941329ad6fb76599347d77f35ec5fe971d_69060_I_1.png"
      },
      {
        "name" => "Solder",
        "description" => "Lead-free rosin core solder for creating clean and reliable electrical joints.",
        "price_tickets" => 45,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/ffc2fe2ea2ffd45081e87cdf2594ee5bcd6d8783_image_21064_1.png"
      },
      {
        "name" => "Fume extractor",
        "description" => "Compact fume extractor with a replaceable filter for safe soldering environments.",
        "price_tickets" => 130,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/243dd974911836fff322dd427d82b1a8a916bb33_71RFQCEAcXL._AC_SY300_SX300_QL70_FMwebp__1.png"
      },
      {
        "name" => "Helping Hands",
        "description" => "A soldering aid with adjustable clips and a magnifier to hold components in place.",
        "price_tickets" => 60,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/cadc4fac7e9f437af281998ee29453ce7055e3c8_60501_W3_1.png"
      },
      {
        "name" => "Solder wick",
        "description" => "Copper braid used for desoldering and removing excess solder from circuit boards.",
        "price_tickets" => 45,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/8679dcf3e866bd1a2df94e2e72ae378da87da906_81CLiqPC8IL._AC_SY300_SX300_QL70_FMwebp__1.png"
      },
      {
        "name" => "Heat gun",
        "description" => "1500-watt dual-temperature heat gun for heat-shrinking, paint removal, and solder reflow.",
        "price_tickets" => 100,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/2ae2e16f1c1baec94328fade8d6fe88dc90465e8_56434_W3_1.png"
      },
      {
        "name" => "Bench power supply",
        "description" => "Adjustable 30V 10A bench power supply for testing circuits with precise voltage control.",
        "price_tickets" => 150,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/970685828af405ed2638cd6c8c41153cb912174d_773abd18-5b3e-4a0f-99b4-14e176bd6ac9_1.png"
      },
      {
        "name" => "3d printer filament",
        "description" => "High-quality PLA filament compatible with most FDM 3D printers for strong, smooth prints.",
        "price_tickets" => 80,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/b1f882adad72925c9b31dabcf025729042a0f685_41q1clgZFRL._SX342_SY445_QL70_FMwebp__1.png"
      },
      {
        "name" => "Mini hot-plate",
        "description" => "Compact electric hot plate for preheating PCBs and assisting in solder reflow processes.",
        "price_tickets" => 80,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/ae6b19d2c1f1e6105d0ccc0f1ff7ef814207eed7_Se7224b46436042ee95deb860bf4338d7P.jpg_960x960q75.jpg__1.png"
      },
      {
        "name" => "Silicone Soldering Mat",
        "description" => "Heat-resistant silicone mat to protect work surfaces and organize small parts during soldering.",
        "price_tickets" => 50,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/42a39c1459de64f557e99432458a592cd686aa87_S03e5fec5fda54e86939088045b9b1299f.jpg_960x960q75.jpg__1.png"
      },
      {
        "name" => "Ender 3 3d printer",
        "description" => "Affordable and reliable FDM 3D printer ideal for hobbyists and rapid prototyping projects.",
        "price_tickets" => 550,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/135898952d6cd708ed705b3ddef31b1569073339_f8f5cb18e72945d332263eb7e4209d23_1.png"
      },
      {
        "name" => "Bambu Lab A1 Mini",
        "description" => "Compact 3D printer with automatic calibration and high-speed printing capabilities.",
        "price_tickets" => 800,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/b513aafccd8e4f295a18dabaad2e4633dcc67b4b_Group48089_1.png"
      },
      {
        "name" => "Bambu Lab P1S",
        "description" => "High-performance enclosed 3D printer designed for speed, reliability, and multi-material support.",
        "price_tickets" => 1700,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/73a790a26c5e9e5c6253e9804dc35d77bfb3b0eb_6_9061.png"
      },
      {
        "name" => "Bambu Lab H2D (base)",
        "description" => "Flagship high-end 3D printer offering industrial-grade precision and advanced automation.",
        "price_tickets" => 6100,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/d218a6c877367ba8e654d0eefab4b4c5cb749ba7_2_76.png"
      },
      {
        "name" => "CNC Router",
        "description" => "Precision desktop CNC router for cutting, engraving, and milling wood, plastic, and aluminum.",
        "price_tickets" => 1400,
        "image_url" => "https://hc-cdn.hel1.your-objectstorage.com/s/v3/d735b5a6f1a102e0bc5f20488b802cffa7f6db25_Cubiko-12001_1.png"
      }
    ]
  end
end
