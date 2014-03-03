require_relative './spec_helper'

describe MongodbBroker do
  describe 'GET /v2/catalog' do
    context 'when Basic Auth is not provided' do
      it 'returns an HTTP 401' do
        get '/v2/catalog'
        last_response.status.should eq 401
      end
    end

    context 'when invalid Basic Auth is provided' do
      it 'returns an HTTP 401' do
        authorize 'badname', 'badpass'
        get '/v2/catalog'
        last_response.status.should eq 401
      end
    end

    context 'when valid Basic Auth is provided' do
      it 'returns an HTTP 200' do
        authorize 'admin', 'admin'
        get '/v2/catalog'
        last_response.status.should eq 200
      end
    end
  end
end
