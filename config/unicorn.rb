workers = ENV['WORKER_COUNT'].to_i
workers = 4 if workers == 0

rails_env = ENV['RAILS_ENV']
worker_processes workers

preload_app true
timeout 300

BASE_PATH = "/home/deploy/shonda.org.uk"
APP_PATH = "#{BASE_PATH}/current"
working_directory APP_PATH

stderr_path File.expand_path("#{BASE_PATH}/shared/log/unicorn.stderr.log", __FILE__)
stdout_path File.expand_path("#{BASE_PATH}/shared/pids/unicorn.stdout.log", __FILE__)

pid "#{APP_PATH}/tmp/pids/unicorn.pid"
pid File.expand_path("#{BASE_PATH}/shared/pids/unicorn.pid", __FILE__)

listen "/tmp/unicorn.shonda.sock", :backlog => 64

# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(root, 'Gemfile')
end

before_fork do |server, worker|
# This option works in together with preload_app true setting
# What is does is prevent the master process from holding
# the database connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
# Here we are establishing the connection after forking worker
# processes
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
