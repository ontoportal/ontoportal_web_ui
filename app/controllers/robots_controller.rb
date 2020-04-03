class RobotsController < ApplicationController
  def index
    # Slices (subdomains) should not be indexed
    if @subdomain_filter[:active]
      robots = <<-EOF.gsub(/^\s+/, "")
        User-agent: *\n
        Disallow: /
      EOF
    else
      robots = File.read(Rails.root + "config/robots/#{Rails.env}.txt")
    end
    render plain: robots
  end
end
