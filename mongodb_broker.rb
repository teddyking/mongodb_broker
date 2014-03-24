require 'json'
require 'sinatra/base'
require 'yaml'
require_relative './mongodb_service_helper'

class MongodbBroker < Sinatra::Base
  before do
    content_type 'application/json'
  end

  use Rack::Auth::Basic do |username, password|
    credentials = app_settings[:basic_auth]
    username == credentials[:username] && password == credentials[:password]
  end

  # Catalog management
  get '/v2/catalog' do
    catalog.to_json
  end

  # Provisioning
  # Note: A new DB isn't actually provisioned here as that's not really
  # possible in MongoDB. This method just checks that there isn't a
  # conflicting resource.
  put '/v2/service_instances/:id' do |id|
    if mongodb_service.database_exists?(id)
      status 409
      { description: 'Database already exists' }.to_json
    else
      status 201
      { dashboard_url: '' }.to_json
    end
  end

  # Binding
  put '/v2/service_instances/:instance_id/service_bindings/:id' do
    instance_id = params[:instance_id]  # database name
    binding_id = params[:id]            # username

    if mongodb_service.user_exists?(instance_id, binding_id)
      status 409
      { description: "The binding #{binding_id} already exists" }.to_json
    else
      mongodb_service.create_user(instance_id, binding_id, binding_password)
      uri = "mongodb://#{binding_id}:#{binding_password}@#{mongodb_host}:#{mongodb_port}/#{instance_id}"
      credentials = {
        uri: uri, username: binding_id, password: binding_password,
        host: mongodb_host, port: mongodb_port, database: instance_id
      }

      status 201
      { 'credentials' => credentials }.to_json
    end
  end

  # Unbinding
  delete '/v2/service_instances/:instance_id/service_bindings/:id' do
    instance_id = params[:instance_id]  # database name
    binding_id = params[:id]            # username

    if mongodb_service.user_exists?(instance_id, binding_id)
      mongodb_service.delete_user(instance_id, binding_id)

      status 200
      {}.to_json
    else
      status 410
      { description: "The binding #{binding_id} doesn't exist" }.to_json
    end
  end

  # Unprovisioning
  delete '/v2/service_instances/:id' do |id|
    if mongodb_service.database_exists?(id)
      mongodb_service.delete_database(id)

      status 200
      {}.to_json
    else
      status 410
      { description: "The database #{id} doesn't exist" }.to_json
    end
  end

  private

  def self.app_settings
    recursive_symbolize_keys(YAML.load(File.open('config/mongodb_broker.yml')))
  end

  def self.recursive_symbolize_keys(h)
    # This method was posted on stackoverflow by user 'pje'
    # http://tinyurl.com/o4yyk4m
    case h
    when Hash
      Hash[
        h.map do |k, v|
          [k.respond_to?(:to_sym) ? k.to_sym : k, recursive_symbolize_keys(v)]
        end
      ]
    when Enumerable
      h.map { |v| recursive_symbolize_keys(v) }
    else
      h
    end
  end

  def binding_password
    @binding_password ||= SecureRandom.urlsafe_base64
  end

  def catalog
    self.class.app_settings[:catalog]
  end

  def mongodb_host
    self.class.app_settings[:mongodb_service][:host]
  end

  def mongodb_port
    self.class.app_settings[:mongodb_service][:port]
  end

  def mongodb_service
    @mongodb_service ||= begin
      uri = "mongodb://#{mongodb_host}:#{mongodb_port}"
      mongo_srv_helper = MongodbServiceHelper.new(uri)
      mongo_srv_helper.establish_connection
      mongo_srv_helper
    end
  end
end
