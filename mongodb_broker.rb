require 'json'
require 'sinatra/base'
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

  private

  def self.app_settings
    {
      basic_auth: { username: 'admin', password: 'admin' },
      mongodb_service: { host: 'localhost', port: 27_017 }
    }
  end

  def binding_password
    'password'
  end

  def catalog
    {
      services: [
        id: 'ae6c4cd4-90cd-40fc-a677-8d3b9a06f8e4',
        name: 'mongodb',
        description: 'MongoDB for everyone!',
        bindable: true,
        plans: [
          id: '5d5d6cbd-ab1f-4f28-84e7-a994446ed910',
          name: 'free',
          description: 'free-tier MongoDB.'
        ]
      ]
    }
  end

  def mongodb_host
    credentials = self.class.app_settings[:mongodb_service]
    credentials[:host]
  end

  def mongodb_port
    credentials = self.class.app_settings[:mongodb_service]
    credentials[:port]
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
