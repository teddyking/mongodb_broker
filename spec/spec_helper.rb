ENV['RACK_ENV'] = 'test'

require_relative '../mongodb_broker'

require 'json'
require 'rack/test'
require 'rspec'

def app
  MongodbBroker
end

RSpec.configure do |c|
  c.include Rack::Test::Methods
end
