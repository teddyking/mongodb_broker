require 'json'
require 'sinatra/base'
require_relative './mongodb_service_helper'

class MongodbBroker < Sinatra::Base
  before do
    content_type 'application/json'
  end

  use Rack::Auth::Basic do |username, password|
    credentials = app_settings[:basic_auth]
    username == credentials[:username] and password == credentials[:password]
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
      {:description => 'Database already exists'}.to_json
    else
      status 201
      {:dashboard_url => ''}.to_json
    end
  end

  private

  def self.app_settings
    {
      basic_auth: { username: 'admin', password: 'admin' },
      mongodb_service: { host: 'localhost', port: 27017 }
    }
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

  def mongodb_service
    credentials = self.class.app_settings[:mongodb_service]
    uri = "mongodb://#{credentials[:host]}:#{credentials[:port]}"
    mongo_srv_helper = MongodbServiceHelper.new(uri)
    mongo_srv_helper.establish_connection
    mongo_srv_helper
  end
end
