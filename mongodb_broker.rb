require 'json'
require 'sinatra/base'

class MongodbBroker < Sinatra::Base
  before do
    content_type 'application/json'
  end

  get '/v2/catalog' do

  end
end
