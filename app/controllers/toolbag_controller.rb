class ToolbagController < ApplicationController
  def index
    @items = [
      {
        "name" => "Wire strippers",
        "description" => "A 7-inch wire stripper with a built-in cutter for cleanly removing insulation from electrical wires.",
        "price_tickets" => 50,
        "image_url" => "shop/wire-strippers.webp"
      },
      {
        "name" => "Flush Cutters",
        "description" => "Compact micro flush cutters ideal for trimming wire ends and plastic parts with precision.",
        "price_tickets" => 50,
        "image_url" => "shop/flush-cutters.webp"
      },
      {
        "name" => "Needle-nose pliers",
        "description" => "Slim 5-3/4 inch pliers for gripping, bending, and manipulating small wires or components.",
        "price_tickets" => 50,
        "image_url" => "shop/needle-nose-pliers.webp"
      },
      {
        "name" => "Precision screwdrivers",
        "description" => "A 33-piece precision screwdriver set for small electronics and detailed mechanical work.",
        "price_tickets" => 70,
        "image_url" => "shop/precision-screwdrivers.webp"
      },
      {
        "name" => "Safety Glasses",
        "description" => "Clear protective eyewear designed to shield eyes from solder splashes and debris.",
        "price_tickets" => 40,
        "image_url" => "shop/safety-glasses.webp"
      },
      {
        "name" => "Digital multimeter",
        "description" => "A 7-function multimeter for measuring voltage, current, and resistance in circuits.",
        "price_tickets" => 60,
        "image_url" => "shop/digital-multimeter.webp"
      },
      {
        "name" => "Soldering Iron",
        "description" => "A lightweight 30W soldering iron perfect for electronics assembly and repair work.",
        "price_tickets" => 70,
        "image_url" => "shop/soldering-iron.webp"
      },
      {
        "name" => "Solder",
        "description" => "Lead-free rosin core solder for creating clean and reliable electrical joints.",
        "price_tickets" => 45,
        "image_url" => "shop/solder.webp"
      },
      {
        "name" => "Fume extractor",
        "description" => "Compact fume extractor with a replaceable filter for safe soldering environments.",
        "price_tickets" => 130,
        "image_url" => "shop/fume-extractor.webp"
      },
      {
        "name" => "Helping Hands",
        "description" => "A soldering aid with adjustable clips and a magnifier to hold components in place.",
        "price_tickets" => 60,
        "image_url" => "shop/helping-hands.webp"
      },
      {
        "name" => "Solder wick",
        "description" => "Copper braid used for desoldering and removing excess solder from circuit boards.",
        "price_tickets" => 45,
        "image_url" => "shop/solder-wick.webp"
      },
      {
        "name" => "Heat gun",
        "description" => "1500-watt dual-temperature heat gun for heat-shrinking, paint removal, and solder reflow.",
        "price_tickets" => 100,
        "image_url" => "shop/heat-gun.webp"
      },
      {
        "name" => "Bench power supply",
        "description" => "Adjustable 30V 10A bench power supply for testing circuits with precise voltage control.",
        "price_tickets" => 150,
        "image_url" => "shop/bench-power-supply.webp"
      },
      {
        "name" => "3d printer filament",
        "description" => "High-quality PLA filament compatible with most FDM 3D printers for strong, smooth prints.",
        "price_tickets" => 80,
        "image_url" => "shop/3d-printer-filament.webp"
      },
      {
        "name" => "Mini hot-plate",
        "description" => "Compact electric hot plate for preheating PCBs and assisting in solder reflow processes.",
        "price_tickets" => 80,
        "image_url" => "shop/mini-hot-plate.webp"
      },
      {
        "name" => "Silicone Soldering Mat",
        "description" => "Heat-resistant silicone mat to protect work surfaces and organize small parts during soldering.",
        "price_tickets" => 50,
        "image_url" => "shop/silicone-soldering-mat.webp"
      },
      {
        "name" => "Ender 3 3d printer",
        "description" => "Affordable and reliable FDM 3D printer ideal for hobbyists and rapid prototyping projects.",
        "price_tickets" => 550,
        "image_url" => "shop/ender-3-3d-printer.webp"
      },
      {
        "name" => "Bambu Lab A1 Mini",
        "description" => "Compact 3D printer with automatic calibration and high-speed printing capabilities.",
        "price_tickets" => 800,
        "image_url" => "shop/bambu-lab-a1-mini.webp"
      },
      {
        "name" => "Bambu Lab P1S",
        "description" => "High-performance enclosed 3D printer designed for speed, reliability, and multi-material support.",
        "price_tickets" => 1700,
        "image_url" => "shop/bambu-lab-p1s.webp"
      },
      {
        "name" => "Bambu Lab H2D (base)",
        "description" => "Flagship high-end 3D printer offering industrial-grade precision and advanced automation.",
        "price_tickets" => 6100,
        "image_url" => "shop/bambu-lab-h2d-base.webp"
      },
      {
        "name" => "CNC Router",
        "description" => "Precision desktop CNC router for cutting, engraving, and milling wood, plastic, and aluminum.",
        "price_tickets" => 1400,
        "image_url" => "shop/cnc-router.webp"
      }
    ]
  end
end
