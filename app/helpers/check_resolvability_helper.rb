require 'benchmark'
require 'ipaddr'
require 'net/http'
require 'resolv'
require 'timeout'
require 'uri'

module CheckResolvabilityHelper

  RESOLVABILITY_ALLOWED_SCHEMES = %w[http https].freeze
  RESOLVABILITY_ALLOWED_PORT_RANGE = 1..65_535
  RESOLVABILITY_BLOCKED_HOSTNAMES = %w[localhost localhost.localdomain].freeze
  RESOLVABILITY_BLOCKED_IP_RANGES = %w[
    0.0.0.0/8
    10.0.0.0/8
    100.64.0.0/10
    127.0.0.0/8
    169.254.0.0/16
    172.16.0.0/12
    192.0.0.0/24
    192.0.2.0/24
    192.88.99.0/24
    192.168.0.0/16
    198.18.0.0/15
    198.51.100.0/24
    203.0.113.0/24
    224.0.0.0/4
    240.0.0.0/4
    255.255.255.255/32
    ::/128
    ::1/128
    ::/96
    ::ffff:0:0/96
    64:ff9b::/96
    64:ff9b:1::/48
    100::/64
    100:0:0:1::/64
    2001::/23
    2001:2::/48
    2001:db8::/32
    2002::/16
    3fff::/20
    5f00::/16
    fc00::/7
    fe80::/10
    fec0::/10
    ff00::/8
  ].map { |range| IPAddr.new(range) }.freeze

  def formats_equivalents(format = nil)
    all = {
      'application/json' => ['application/ld+json'],
      'application/rdf+xml' => %w[application/xml text/xml text/rdf+xml application/octet-stream],
      'text/turtle' => %w[application/turtle application/octet-stream],
      'text/n3' => %w[text/rdf+n3 application/rdf+n3 application/n3 application/n-triples text/n-triples application/ntriples text/ntriples],
      'text/html' => []
    }

    return all unless format

    all[format]
  end

  def resolvability_formats
    formats_equivalents.keys
  end

  def resolvability_timeout
    5
  end

  def resolvability_max_redirections
    10
  end

  def resolvability_status(status, allowed_format, redirections, result: nil, response_time:0)

    supported_format = Array(allowed_format)
    unless result
      supported_format += redirections.map { |k, v| v[:status].to_s.eql?('200') && v[:allowed_format] }.compact
      supported_format.uniq!
      if supported_format.size > 1
        result = 2 # negotiable
      elsif !supported_format.empty?
        result = 1 # resolvable
      end
    end

    { result: result, status: status, allowed_format: supported_format, response_time: response_time, redirections: redirections }
  end

  def check_resolvability_error(key)
    I18n.t("check_resolvability.errors.#{key}")
  end

  def public_resolvability_uri(url)
    raw_url = url.to_s.strip
    raise ArgumentError, check_resolvability_error(:url_required) if raw_url.empty?

    uri = URI.parse(raw_url)
    unless uri.is_a?(URI::HTTP) && RESOLVABILITY_ALLOWED_SCHEMES.include?(uri.scheme)
      raise ArgumentError, check_resolvability_error(:http_only)
    end

    raise ArgumentError, check_resolvability_error(:host_required) if uri.hostname.to_s.empty?
    raise ArgumentError, check_resolvability_error(:credentials_forbidden) if uri.userinfo
    raise ArgumentError, check_resolvability_error(:invalid_port) unless RESOLVABILITY_ALLOWED_PORT_RANGE.cover?(uri.port)

    uri
  rescue URI::Error
    raise ArgumentError, check_resolvability_error(:invalid_url)
  end

  def public_resolvability_hostname(uri)
    uri.hostname.to_s.downcase.delete_suffix('.')
  end

  def public_resolvability_connection_ip(uri, timeout_seconds = resolvability_timeout)
    host = public_resolvability_hostname(uri)
    raise ArgumentError, check_resolvability_error(:host_required) if host.empty?

    if RESOLVABILITY_BLOCKED_HOSTNAMES.include?(host) || host.end_with?('.localhost')
      raise ArgumentError, check_resolvability_error(:non_public_host)
    end

    ip_literal = parse_resolvability_ip(host)
    addresses = ip_literal ? [ip_literal.to_s] : public_resolvability_dns_addresses(host, timeout_seconds)

    if addresses.empty? || addresses.any? { |address| !public_resolvability_ip_address?(address) }
      raise ArgumentError, check_resolvability_error(:non_public_address)
    end

    addresses.first.to_s
  end

  def public_resolvability_dns_addresses(host, timeout_seconds = resolvability_timeout)
    if host !~ /[.:]/
      raise ArgumentError, check_resolvability_error(:single_label_host)
    end

    Timeout.timeout(timeout_seconds) { Array(Resolv.getaddresses(host)) }
  rescue Resolv::ResolvError, Timeout::Error
    []
  end

  def public_resolvability_ip_address?(address)
    ip = address.is_a?(IPAddr) ? address : IPAddr.new(address)
    RESOLVABILITY_BLOCKED_IP_RANGES.none? { |range| range.include?(ip) }
  rescue IPAddr::Error
    false
  end

  def parse_resolvability_ip(address)
    IPAddr.new(address)
  rescue IPAddr::Error
    nil
  end

  def public_resolvability_redirect_uri(uri, location)
    location = location.to_s.strip
    raise ArgumentError, check_resolvability_error(:invalid_redirect) if location.empty?

    joined_uri = begin
      URI.join(uri, location)
    rescue URI::Error
      raise ArgumentError, check_resolvability_error(:invalid_redirect)
    end

    public_resolvability_uri(joined_uri.to_s)
  end

  def resolvability_request_uri(uri)
    request_uri = uri.request_uri
    request_uri.nil? || request_uri.empty? ? '/' : request_uri
  end

  def follow_redirection(url, format, timeout_seconds, redirect_limit = resolvability_max_redirections)
    uri = public_resolvability_uri(url)
    response = nil
    redirect_count = 0
    redirections = [uri]

    total_time = Benchmark.measure do
      until (!response.nil? && !response.is_a?(Net::HTTPRedirection)) || redirect_count >= redirect_limit
        connection_ip = public_resolvability_connection_ip(uri, timeout_seconds)
        http = Net::HTTP.new(public_resolvability_hostname(uri), uri.port, nil)
        unless http.respond_to?(:ipaddr=)
          raise ArgumentError, check_resolvability_error(:ip_pinning_unavailable)
        end
        http.ipaddr = connection_ip
        http.use_ssl = (uri.scheme == 'https')
        http.open_timeout = timeout_seconds
        http.read_timeout = timeout_seconds if http.respond_to?(:read_timeout=)
        begin
          response = Timeout.timeout(timeout_seconds) { http.request_head(resolvability_request_uri(uri), 'Accept' => format) }
        rescue Timeout::Error, Net::OpenTimeout
          return resolvability_status('Timeout', [], redirections, result: 0, response_time: timeout_seconds)
        end

        if response.is_a?(Net::HTTPRedirection)
          break if response['location'].to_s.strip.empty?

          uri = public_resolvability_redirect_uri(uri, response['location'])
          public_resolvability_connection_ip(uri, timeout_seconds)
          redirections << uri
          redirect_count += 1
        end
      end
    end

    if redirect_count >= redirect_limit
      resolvability_status('Too Many Redirections', [], redirections, result: 0, response_time: total_time.real.round(3))
    else
      if response&.code.to_s.eql?('200') && (response&.content_type.to_s.include?(format) || formats_equivalents(format)&.include?(response&.content_type.to_s))
        result = 2
      elsif response&.code.to_s.eql?('200')
        result = 1
      else
        result = 0
      end
      resolvability_status(response&.code, [response&.content_type], redirections, result: result, response_time: total_time.real.round(3))
    end
  end

  def check_resolvability_helper(url, negotiation_formats = resolvability_formats, timeout_seconds = resolvability_timeout)
    redirections = {}
    supported_format = negotiation_formats.find_all do |format|
      begin
        redirections[format] = follow_redirection(url, format, timeout_seconds)
        redirections[format][:result].eql?(2)
      rescue StandardError => e
        redirections[format] = resolvability_status(e.message, [], [], result: 0)
        false
      end
    end

    status = redirections.values.map { |v| v[:status] }.uniq.join(', ')
    average_response_time = redirections.values.sum { |v| v[:response_time] }.fdiv(redirections.size).round(3)
    if supported_format.size > 1
      { result: 2, status: status, allowed_format: supported_format, average_response_time: average_response_time, redirections: redirections }
    elsif status.include?('200')
      returned_format = redirections.map { |k, v| !v[:result].eql?(0) ? v[:allowed_format] : nil }.flatten.compact.uniq
      { result: 1, status: status, allowed_format: returned_format,  average_response_time: average_response_time, redirections: redirections }
    else
      { result: 0, status: status, allowed_format: [],  average_response_time: average_response_time, redirections: redirections }
    end

  end

  def url_resolvable?(result)
    result[:result].eql?(1) || url_content_negotiable?(result)
  end

  def url_content_negotiable?(result)
    result[:result].eql?(2)
  end

  def check_resolvability_success(result)
    url_resolvable?(result) || url_content_negotiable?(result)
  end

  def check_resolvability_message(resolvable, allowed_formats, status, url: nil, response_time: nil)
    supported_format = Array(allowed_formats).compact
    supported_format = allowed_formats.empty? ? 'Format not specified' : supported_format.join(', ')

    if resolvable && (supported_format.size > 1)
      text = t('check_resolvability.check_resolvability_message_1', supported_format: supported_format)
    elsif resolvable
      text = t('check_resolvability.check_resolvability_message_2', supported_format: supported_format)
    else
      text = t('check_resolvability.check_resolvability_message_3', status: status)
    end


    text = text + link_to(', click to see details', check_resolvability_path(url: url), target: '_blank') if url
    text += " (Average response time: #{response_time}s)" if response_time
    text
  end

  # Resolve subject URIs
  def resolve_subject_uri(subject, theme_taxonomy_ontologies)
    # Normalize the subject for consistent caching (e.g., strip whitespace)
    normalized_subject = subject.strip


    text = normalized_subject
    url = normalized_subject

    unless theme_taxonomy_ontologies.empty?
      theme_taxonomy_ontologies.each do |ontology_acronym|
        class_uri = "#{rest_url}/ontologies/#{ontology_acronym}/classes/#{CGI.escape(normalized_subject)}"
        response = LinkedData::Client::HTTP.get(
          class_uri,
          lang: portal_lang,
          display_context: false,
          display_links: false,
          include: "prefLabel"
        )

        if response.prefLabel
          url = class_uri.sub('data.', '')
          text = response.prefLabel
          break
        end
      end
    end

    { text: text, url: url }
  end

end
