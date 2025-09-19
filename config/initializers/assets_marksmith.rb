# Ensure Marksmith CSS is on the propshaft load path
marksmith_gem = Gem.loaded_specs["marksmith"]
if marksmith_gem
  styles_path = File.join(marksmith_gem.full_gem_path, "app/assets/stylesheets")
  Rails.application.config.assets.paths << styles_path if Dir.exist?(styles_path)
end
