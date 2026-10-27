# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

class MappingsAuthenticationRoutesTest < ActionDispatch::IntegrationTest
  test 'anonymous users do not see the mapping upload tab' do
    mapping_counts = Struct.new(:members) do
      def to_h = {}
    end.new([])

    LinkedData::Client::HTTP.stub(:get, mapping_counts) do
      LinkedData::Client::Models::Ontology.stub(:all, []) do
        get '/mappings'
      end
    end

    assert_response :success
    assert_select '.nav-item', text: I18n.t('mappings.tabs.upload_mappings'), count: 0
  end

  test 'anonymous users are redirected from the new mapping form' do
    get '/mappings/new'

    assert_redirected_to '/'
  end

  test 'anonymous users are redirected from mapping upload' do
    post '/mappings/loader'

    assert_redirected_to '/'
  end

  test 'anonymous users are redirected from mapping create' do
    post '/mappings'

    assert_redirected_to '/'
  end

  test 'anonymous users are redirected from every mapping update verb' do
    post '/mappings/1'
    assert_redirected_to '/'

    patch '/mappings/1'
    assert_redirected_to '/'

    put '/mappings/1'
    assert_redirected_to '/'
  end

  test 'anonymous users are redirected from mapping destroy' do
    delete '/mappings/1'

    assert_redirected_to '/'
  end
end

class MappingsControllerAuthenticatedTest < ActionController::TestCase
  tests MappingsController

  ResponseStub = Struct.new(:errors, :created, keyword_init: true)

  setup do
    user = Struct.new(:apikey, :username) do
      def admin? = false
      def flipper_id = username
      def to_hash = to_h
    end.new('test-api-key', 'test-user')

    @request.session[:user] = user
  end

  test 'authenticated upload redirects leave the Turbo frame' do
    mapping_counts = Struct.new(:members) do
      def to_h = {}
    end.new([])

    LinkedData::Client::HTTP.stub(:get, mapping_counts) do
      LinkedData::Client::Models::Ontology.stub(:all, []) do
        get :index
      end
    end

    assert_response :success
    assert_select 'form[data-turbo-frame="_top"]'
  end

  test 'authenticated users can upload mappings' do
    response = ResponseStub.new(errors: nil, created: [])
    upload = fixture_file_upload(Rails.root.join('test/fixtures/annotator.yml'), 'application/json')
    call = nil

    LinkedData::Client::HTTP.stub(:post, ->(*args, **kwargs) {
      call = [args, kwargs]
      response
    }) do
      post :loader_process, params: { file: upload }
    end

    assert_redirected_to '/mappings'
    assert_equal ['/mappings/load'], call.first
    assert_equal upload.original_filename, call.last[:file].original_filename
  end
end
