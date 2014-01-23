workers = ENV['WORKER_COUNT'].to_i
workers = 4 if workers == 0

rails_env = ENV['RAILS_ENV']
worker_processes workers

preload_app true
timeout 300

APP_PATH = "/home/shonda/shonda.org.uk/current"
working_directory APP_PATH

stderr_path "#{APP_PATH}/log/unicorn.log"
stdout_path "#{APP_PATH}/log/unicorn.log"

pid "#{APP_PATH}/tmp/pids/unicorn.pid"

listen "/tmp/unicorn.shonda.sock"

# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(root, 'Gemfile')
end
