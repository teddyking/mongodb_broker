require 'json'
require 'sinatra/base'

class MongodbBroker < Sinatra::Base
  before do
    content_type 'application/json'
  end

  use Rack::Auth::Basic do |username, password|
    credentials = self.app_settings[:basic_auth]
    username == credentials[:username] and password == credentials[:password]
  end

  get '/v2/catalog' do

  end

  private

  def self.app_settings
    {
      :basic_auth => {
        :username => 'admin',
        :password => 'admin'
      }
    }
  end
end
