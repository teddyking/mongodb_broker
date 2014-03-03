require 'json'
require 'sinatra/base'

class MongodbBroker < Sinatra::Base
  before do
    content_type 'application/json'
  end

  use Rack::Auth::Basic do |username, password|
    credentials = app_settings[:basic_auth]
    username == credentials[:username] and password == credentials[:password]
  end

  get '/v2/catalog' do
    catalog.to_json
  end

  private

  def self.app_settings
    {
      basic_auth: { username: 'admin', password: 'admin' }
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
end
