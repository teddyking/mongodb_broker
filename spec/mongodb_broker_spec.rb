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
      before(:each) { authorize 'admin', 'admin' }

      it 'returns an HTTP 200' do
        get '/v2/catalog'
        last_response.status.should eq 200
      end

      it 'returns a JSON response' do
        get '/v2/catalog'
        expect { JSON.parse(last_response.body) }.to_not raise_error
      end

      it 'returns the required response fields' do
        get '/v2/catalog'

        json = JSON.parse(last_response.body)

        json['services'].should_not be nil
        json['services'].length.should be > 0

        json['services'].each do |service|
          %w{id name description bindable plans}.each do |key|
            service[key].should_not be nil
          end

          service['plans'].length.should be > 0
          service['plans'].each do |plan|
            %w{id name description}.each do |key|
              service[key].should_not be nil
            end
          end
        end
      end
    end
  end

  describe 'PUT /v2/service_instances/:id' do
    let(:id) { '1234-abcd-12cd' }
    let(:mongodb_srv_helper) { double("MongodbServiceHelper") }

    context 'when Basic Auth is not provided' do
      it 'returns an HTTP 401' do
        get "/v2/service_instances/#{id}"
        last_response.status.should eq 401
      end
    end

    context 'when invalid Basic Auth is provided' do
      it 'returns an HTTP 401' do
        authorize 'badname', 'badpass'
        get "/v2/service_instances/#{id}"
        last_response.status.should eq 401
      end
    end

    context 'when valid Basic Auth is provided' do
      before(:each) do
        authorize 'admin', 'admin'
        MongodbServiceHelper.should_receive(:new).
          and_return(mongodb_srv_helper)
        mongodb_srv_helper.should_receive(:establish_connection)
      end

      context "when the database resource doesn't already exist" do
        it 'returns a 201' do
          mongodb_srv_helper.should_receive(:database_exists?).with(id).
            and_return(false)

          put "/v2/service_instances/#{id}"
          last_response.status.should eq 201
        end
      end

      context "when the database resouce already exists" do
        it 'returns a 409' do
          mongodb_srv_helper.should_receive(:database_exists?).with(id).
            and_return(true)

          put "/v2/service_instances/#{id}"
          last_response.status.should eq 409
        end
      end
    end
  end
end
