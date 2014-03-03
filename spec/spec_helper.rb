ENV['RACK_ENV'] = 'test'

require_relative '../mongodb_broker'
require_relative '../mongodb_service_helper'

require 'json'
require 'rack/test'
require 'rspec'

def app
  MongodbBroker
end

RSpec.configure do |c|
  c.include Rack::Test::Methods
end
