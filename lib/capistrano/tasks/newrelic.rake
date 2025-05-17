namespace :newrelic do
  task :report_deployment do
    next unless fetch(:newrelic_notice_enabled, false)
    invoke 'newrelic:notice_deployment'
  end
end
