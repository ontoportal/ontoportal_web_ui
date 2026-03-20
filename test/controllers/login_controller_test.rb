# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

class LoginControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fake_user = OpenStruct.new(
      username: 'testuser',
      id: 'testuser',
      apikey: 'fake-api-key',
      admin?: false,
      errors: nil,
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      subscription: nil
    )
  end

  # Stub authentication to avoid hitting the external API.
  # Yields to the block with authentication bypassed.
  def with_stubbed_auth
    LinkedData::Client::Models::User.stub(:authenticate, @fake_user) do
      yield
    end
  end

  # -- Redirect sanitization tests --

  test 'login with no redirect param redirects to root' do
    with_stubbed_auth do
      get login_index_url
      post login_index_url, params: { user: { username: 'testuser', password: 'pass' } }
      assert_redirected_to '/'
    end
  end

  test 'login with valid relative redirect preserves path' do
    with_stubbed_auth do
      get "#{login_index_url}?redirect=%2Fontologies"
      post login_index_url, params: { user: { username: 'testuser', password: 'pass' } }
      assert_redirected_to '/ontologies'
    end
  end

  test 'login with protocol-relative redirect falls back to root' do
    with_stubbed_auth do
      get "#{login_index_url}?redirect=//evil.com"
      post login_index_url, params: { user: { username: 'testuser', password: 'pass' } }
      assert_redirected_to '/'
    end
  end

  test 'login with absolute external URL falls back to root' do
    with_stubbed_auth do
      get "#{login_index_url}?redirect=https://evil.com/phishing"
      post login_index_url, params: { user: { username: 'testuser', password: 'pass' } }
      assert_redirected_to '/'
    end
  end

  test 'login with encoded protocol-relative redirect falls back to root' do
    with_stubbed_auth do
      get "#{login_index_url}?redirect=%2F%2Fevil.com"
      post login_index_url, params: { user: { username: 'testuser', password: 'pass' } }
      assert_redirected_to '/'
    end
  end

  test 'login with backslash redirect falls back to root' do
    with_stubbed_auth do
      get "#{login_index_url}?redirect=\\\\evil.com"
      post login_index_url, params: { user: { username: 'testuser', password: 'pass' } }
      assert_redirected_to '/'
    end
  end

  test 'login with javascript URI falls back to root' do
    with_stubbed_auth do
      get "#{login_index_url}?redirect=javascript:alert(1)"
      post login_index_url, params: { user: { username: 'testuser', password: 'pass' } }
      assert_redirected_to '/'
    end
  end

  test 'login with same-host absolute URL extracts path' do
    with_stubbed_auth do
      get "#{login_index_url}?redirect=http://#{host}/ontologies?p=classes"
      post login_index_url, params: { user: { username: 'testuser', password: 'pass' } }
      assert_redirected_to '/ontologies?p=classes'
    end
  end
end
