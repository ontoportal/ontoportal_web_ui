# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

class CheckResolvabilityHelperTest < ActionView::TestCase
  include CheckResolvabilityHelper

  test 'rejects unsafe URLs before making a request' do
    constructor_called = false

    Net::HTTP.stub(:new, lambda { |*|
      constructor_called = true
      raise 'HTTP client must not be constructed'
    }) do
      result = check_resolvability_helper('http://127.0.0.1/admin', ['text/html'], 1)

      assert_equal 0, result[:result]
      assert_equal translated_error(:non_public_address), result[:status]
    end

    assert_not constructor_called
  end

  test 'rejects invalid and special-purpose URLs' do
    cases = {
      nil => :url_required,
      'file:///etc/passwd' => :http_only,
      'http:///resource' => :host_required,
      'http://user:pass@example.com/' => :credentials_forbidden,
      'http://example/' => :single_label_host,
      'http://localhost/' => :non_public_host,
      'http://example.com:0/' => :invalid_port,
      'http://example.com:65536/' => :invalid_port,
      'http://[broken/' => :invalid_url,
      'http://[::1]/' => :non_public_address,
      'http://[64:ff9b:1::7f00:1]/' => :non_public_address,
      'http://[100:0:0:1::1]/' => :non_public_address,
      'http://[3fff::1]/' => :non_public_address,
      'http://[5f00::1]/' => :non_public_address,
      'http://[fec0::1]/' => :non_public_address
    }

    cases.each do |url, key|
      result = check_resolvability_helper(url, ['text/html'], 1)

      assert_equal 0, result[:result], url.inspect
      assert_equal translated_error(key), result[:status], url.inspect
    end
  end

  test 'rejects hostnames with any private resolved address' do
    stub_public_dns('metadata.example' => ['93.184.216.34', '10.0.0.5']) do
      result = check_resolvability_helper('http://metadata.example/latest', ['text/html'], 1)

      assert_equal 0, result[:result]
      assert_equal translated_error(:non_public_address), result[:status]
    end
  end

  test 'rejects invalid resolved addresses' do
    stub_public_dns('invalid.example' => ['not-an-ip']) do
      result = check_resolvability_helper('http://invalid.example/', ['text/html'], 1)

      assert_equal 0, result[:result]
      assert_equal translated_error(:non_public_address), result[:status]
    end
  end

  test 'revalidates redirects before following them' do
    response = redirect_response('http://169.254.169.254/latest/meta-data')
    fake_http = FakeHeadClient.new(response)
    http_new_calls = 0

    stub_public_dns('public.example' => ['93.184.216.34']) do
      Net::HTTP.stub(:new, lambda { |*args|
        http_new_calls += 1
        assert_equal ['public.example', 80, nil], args
        fake_http
      }) do
        result = check_resolvability_helper('http://public.example/resource', ['text/html'], 1)

        assert_equal 0, result[:result]
        assert_equal translated_error(:non_public_address), result[:status]
      end
    end

    assert_equal 1, http_new_calls
    assert_equal [['/resource', { 'Accept' => 'text/html' }]], fake_http.requests
  end

  test 'follows a safe redirect to a successful response' do
    redirect = redirect_response('https://safe.example/final')
    success = Net::HTTPOK.new('1.1', '200', 'OK')
    success['Content-Type'] = 'text/html'
    fake_http = FakeHeadClient.new(redirect, success)
    constructor_args = []

    stub_public_dns(
      'public.example' => ['93.184.216.34'],
      'safe.example' => ['93.184.216.35']
    ) do
      Net::HTTP.stub(:new, lambda { |*args|
        constructor_args << args
        fake_http
      }) do
        result = check_resolvability_helper('http://public.example/resource', ['text/html'], 1)

        assert_equal 1, result[:result]
      end
    end

    assert_equal [
      ['public.example', 80, nil],
      ['safe.example', 443, nil]
    ], constructor_args
    assert_equal [
      ['/resource', { 'Accept' => 'text/html' }],
      ['/final', { 'Accept' => 'text/html' }]
    ], fake_http.requests
    assert_equal ['93.184.216.34', '93.184.216.35'], fake_http.ipaddrs
  end

  test 'terminates a redirect without a location' do
    fake_http = FakeHeadClient.new(Net::HTTPFound.new('1.1', '302', 'Found'))

    stub_public_dns('public.example' => ['93.184.216.34']) do
      Net::HTTP.stub(:new, ->(*) { fake_http }) do
        result = check_resolvability_helper('http://public.example/resource', ['text/html'], 1)

        assert_equal 0, result[:result]
        assert_equal '302', result[:status]
      end
    end

    assert_equal 1, fake_http.requests.size
  end

  test 'reports malformed redirect locations safely' do
    response = redirect_response('http://[broken')
    fake_http = FakeHeadClient.new(response)

    stub_public_dns('public.example' => ['93.184.216.34']) do
      Net::HTTP.stub(:new, ->(*) { fake_http }) do
        result = check_resolvability_helper('http://public.example/resource', ['text/html'], 1)

        assert_equal 0, result[:result]
        assert_equal translated_error(:invalid_redirect), result[:status]
      end
    end
  end

  test 'disables environment proxies and pins the validated IP' do
    success = Net::HTTPOK.new('1.1', '200', 'OK')
    fake_http = FakeHeadClient.new(success)
    constructor_args = []
    previous_proxy = ENV['http_proxy']
    ENV['http_proxy'] = 'http://127.0.0.1:8888'

    stub_public_dns('public.example' => ['93.184.216.34']) do
      Net::HTTP.stub(:new, lambda { |*args|
        constructor_args << args
        fake_http
      }) do
        result = check_resolvability_helper('http://public.example/resource', ['text/html'], 1)

        assert_equal 1, result[:result]
      end
    end

    assert_equal [['public.example', 80, nil]], constructor_args
    assert_equal ['93.184.216.34'], fake_http.ipaddrs
  ensure
    if previous_proxy.nil?
      ENV.delete('http_proxy')
    else
      ENV['http_proxy'] = previous_proxy
    end
  end

  test 'allows a public hostname on a valid non-default port' do
    success = Net::HTTPOK.new('1.1', '200', 'OK')
    fake_http = FakeHeadClient.new(success)
    constructor_args = []

    stub_public_dns('public.example' => ['93.184.216.34']) do
      Net::HTTP.stub(:new, lambda { |*args|
        constructor_args << args
        fake_http
      }) do
        result = check_resolvability_helper('http://public.example:8080/resource', ['text/html'], 1)

        assert_equal 1, result[:result]
      end
    end

    assert_equal [['public.example', 8080, nil]], constructor_args
    assert_equal ['93.184.216.34'], fake_http.ipaddrs
  end

  test 'uses the unbracketed hostname for public IPv6 literals' do
    success = Net::HTTPOK.new('1.1', '200', 'OK')
    fake_http = FakeHeadClient.new(success)
    constructor_args = []

    Net::HTTP.stub(:new, lambda { |*args|
      constructor_args << args
      fake_http
    }) do
      result = check_resolvability_helper('http://[2001:4860:4860::8888]/resource', ['text/html'], 1)

      assert_equal 1, result[:result]
    end

    assert_equal [['2001:4860:4860::8888', 80, nil]], constructor_args
    assert_equal ['2001:4860:4860::8888'], fake_http.ipaddrs
  end

  test 'localizes rejection statuses in French' do
    I18n.with_locale(:fr) do
      result = check_resolvability_helper('http://127.0.0.1/', ['text/html'], 1)

      assert_equal I18n.t('check_resolvability.errors.non_public_address'), result[:status]
      refute_equal I18n.t('check_resolvability.errors.non_public_address', locale: :en), result[:status]
    end
  end

  test 'reports missing IP pinning support' do
    success = Net::HTTPOK.new('1.1', '200', 'OK')

    stub_public_dns('public.example' => ['93.184.216.34']) do
      Net::HTTP.stub(:new, ->(*) { NoPinningClient.new(success) }) do
        result = check_resolvability_helper('http://public.example/', ['text/html'], 1)

        assert_equal 0, result[:result]
        assert_equal translated_error(:ip_pinning_unavailable), result[:status]
      end
    end
  end

  private

  class FakeHeadClient
    attr_accessor :ipaddr, :open_timeout, :read_timeout, :use_ssl
    attr_reader :requests, :ipaddrs

    def initialize(*responses)
      @responses = responses
      @requests = []
      @ipaddrs = []
    end

    def ipaddr=(address)
      @ipaddrs << address
      @ipaddr = address
    end

    def request_head(path, headers)
      @requests << [path, headers]
      @responses.shift || @responses.last
    end
  end

  class NoPinningClient
    def initialize(response)
      @response = response
    end

    def request_head(*); @response; end
  end

  def redirect_response(location)
    response = Net::HTTPFound.new('1.1', '302', 'Found')
    response['Location'] = location
    response
  end

  def stub_public_dns(mapping)
    Resolv.stub(:getaddresses, ->(host) { mapping.fetch(host) { [] } }) { yield }
  end

  def translated_error(key)
    I18n.t("check_resolvability.errors.#{key}")
  end
end
