namespace :config do
  desc 'Sync configuration files from private repo or local path into the release'
  task :sync do
    if fetch(:private_config_repo, nil)
      tmp_path = "/tmp/#{SecureRandom.hex(15)}"
      on roles(:app) do
        info "Fetching configuration from private repo"  # Do NOT log the URL
        execute "git clone -q #{fetch(:private_config_repo)} #{tmp_path}"
        execute "rsync -a #{tmp_path}/#{fetch(:application)}/ #{release_path}/"
        execute "rm -rf #{tmp_path}"
      end

    elsif ENV['LOCAL_CONFIG_PATH']
      on roles(:app) do
        info "Fetching configuration from local path"
        execute "rsync -a #{ENV['LOCAL_CONFIG_PATH']}/#{fetch(:application)}/ #{release_path}/"
      end

    else
      on roles(:app) do
        warn "No PRIVATE_CONFIG_REPO or LOCAL_CONFIG_PATH provided. Skipping configuration injection."
      end
    end
  end
end
