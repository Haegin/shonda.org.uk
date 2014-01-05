CarrierWave.configure do |config|

  config.cache_dir = File.join(Rails.root, 'tmp', 'uploads')

  # settings for the local filesystem
  config.storage = :file
  config.root = File.join(Rails.root, 'public')

end
