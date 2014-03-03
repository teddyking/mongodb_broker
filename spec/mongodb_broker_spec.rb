require_relative './spec_helper'

describe MongodbBroker do
  describe 'GET /v2/catalog' do
    it 'returns an HTTP 200' do
      get '/v2/catalog'
      last_response.status.should eq 200
    end
  end
end
