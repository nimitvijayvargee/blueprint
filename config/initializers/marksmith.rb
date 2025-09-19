Marksmith.configure do |config|
  config.automatically_mount_engine = true
  config.mount_path = "/marksmith"
  # Use Redcarpet but with our local renderer override
  config.parser = "redcarpet"
end
