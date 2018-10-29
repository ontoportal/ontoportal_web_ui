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
    render text: robots, layout: false, content_type: 'text/plain'
  end
end
