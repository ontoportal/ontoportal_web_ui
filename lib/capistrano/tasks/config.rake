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

    elsif fetch(:local_config_path, nil)
      on roles(:app) do
        info "Fetching configuration from local path"
        execute "rsync -a #{fetch(:local_config_path)}/#{fetch(:application)}/ #{release_path}/"
      end

    else
      on roles(:app) do
        warn <<~MSG
          Skipping configuration injection: no configuration source defined.
          To fix this, set one of the following:

          - Capistrano variable :private_config_repo (e.g. in stage file or via -s)
          - Capistrano variable :local_config_path (or set LOCAL_CONFIG_PATH env var)

          Example usage:
            CONFIG_PATH=/path/to/config cap appliance deploy
            or
            cap appliance deploy -s local_config_path=/path/to/config
        MSG
      end
    end
  end
end
