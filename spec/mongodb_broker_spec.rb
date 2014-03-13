require_relative './spec_helper'

# Some of this needs DRYing up, especially the basic auth checks
describe MongodbBroker do
  describe 'GET /v2/catalog' do
    let(:make_request) { get '/v2/catalog' }

    context 'when Basic Auth is not provided' do
      it 'returns an HTTP 401' do
        make_request
        last_response.status.should eq 401
      end
    end

    context 'when invalid Basic Auth is provided' do
      it 'returns an HTTP 401' do
        authorize 'badname', 'badpass'

        make_request
        last_response.status.should eq 401
      end
    end

    context 'when valid Basic Auth is provided' do
      before(:each) { authorize 'admin', 'admin' }

      it 'returns an HTTP 200' do
        make_request
        last_response.status.should eq 200
      end

      it 'returns a JSON response' do
        make_request
        expect { JSON.parse(last_response.body) }.to_not raise_error
      end

      it 'returns the required response fields' do
        make_request

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
    let(:make_request) { put "/v2/service_instances/#{instance_id}" }

    context 'when Basic Auth is not provided' do
      it 'returns an HTTP 401' do
        make_request
        last_response.status.should eq 401
      end
    end

    context 'when invalid Basic Auth is provided' do
      it 'returns an HTTP 401' do
        authorize 'badname', 'badpass'

        make_request
        last_response.status.should eq 401
      end
    end

    context 'when valid Basic Auth is provided' do
      before(:each) do
        authorize 'admin', 'admin'
        mock_mongodb_service_helper
      end

      context "when the database resource doesn't already exist" do
        before(:each) do
          mongodb_srv_helper.should_receive(:database_exists?)
            .with(instance_id).and_return(false)
        end

        it 'returns an HTTP 201' do
          make_request

          last_response.status.should eq 201
        end

        it 'returns dashboard_url in the JSON response' do
          make_request

          json = JSON.parse(last_response.body)
          json['dashboard_url'].should_not be nil
        end
      end

      context 'when the database resouce already exists' do
        it 'returns an HTTP 409' do
          mongodb_srv_helper.should_receive(:database_exists?)
            .with(instance_id).and_return(true)

          make_request
          last_response.status.should eq 409
        end
      end
    end
  end

  describe 'PUT /v2/service_instances/:instance_id/service_bindings/:id' do
    let(:make_request) { put "/v2/service_instances/#{instance_id}/service_bindings/#{binding_id}" }

    context 'when Basic Auth is not provided' do
      it 'returns an HTTP 401' do
        make_request
        last_response.status.should eq 401
      end
    end

    context 'when invalid Basic Auth is provided' do
      it 'returns an HTTP 401' do
        authorize 'badname', 'badpass'
        make_request
        last_response.status.should eq 401
      end
    end

    context 'when valid Basic Auth is provided' do
      before(:each) do
        authorize 'admin', 'admin'
        mock_mongodb_service_helper
      end

      context "when the binding resource doesn't already exist" do
        before(:each) do
          mongodb_srv_helper.should_receive(:user_exists?)
            .with(instance_id, binding_id).and_return(false)
          mongodb_srv_helper.should_receive(:create_user)
            .with(instance_id, binding_id, valid_password)
        end

        it 'returns an HTTP 201' do
          make_request
          last_response.status.should eq 201
        end

        it 'returns a credentials Hash' do
          make_request

          json = JSON.parse(last_response.body)
          json['credentials'].should_not be nil
        end

        it 'returns a mongodb connection uri in the credentials Hash' do
          make_request

          json = JSON.parse(last_response.body)
          uri = json['credentials']['uri']
          uri.should match /mongodb:\/\/#{binding_id}:#{valid_password}@localhost:27017\/#{instance_id}/
        end

        it 'returns the individual credentials in the credentials Hash' do
          make_request

          json = JSON.parse(last_response.body)
          %w{uri username password host port database}.each do |credential|
            json['credentials'][credential].should_not be nil
          end
        end
      end

      context 'when the binding resource already exists' do
        it 'returns an HTTP 409' do
          mongodb_srv_helper.should_receive(:user_exists?)
            .with(instance_id, binding_id).and_return(true)

          make_request
          last_response.status.should eq 409
        end
      end
    end
  end

  describe 'DELETE /v2/service_instances/:instance_id/service_bindings/:id' do
    let(:make_request) { delete "/v2/service_instances/#{instance_id}/service_bindings/#{binding_id}" }

    context 'when Basic Auth is not provided' do
      it 'returns an HTTP 401' do
        make_request
        last_response.status.should eq 401
      end
    end

    context 'when invalid Basic Auth is provided' do
      it 'returns an HTTP 401' do
        authorize 'badname', 'badpass'
        make_request
        last_response.status.should eq 401
      end
    end

    context 'when valid Basic Auth is provided' do
      before(:each) do
        authorize 'admin', 'admin'
        mock_mongodb_service_helper
      end

      context 'when the binding resource exists' do
        before(:each) do
          mongodb_srv_helper.should_receive(:user_exists?)
            .with(instance_id, binding_id).and_return(true)
          mongodb_srv_helper.should_receive(:delete_user)
            .with(instance_id, binding_id)
        end

        it 'returns an HTTP 200' do
          make_request
          last_response.status.should eq 200
        end

        it 'returns {} in the body' do
          make_request
          last_response.body.should eq '{}'
        end
      end

      context "when the binding resource doesn't already exist" do
        it 'returns an HTTP 410' do
          mongodb_srv_helper.should_receive(:user_exists?)
            .with(instance_id, binding_id).and_return(false)

          make_request
          last_response.status.should eq 410
        end
      end
    end
  end

  describe 'DELETE /v2/service_instances/:id' do
    let(:make_request) { delete "/v2/service_instances/#{instance_id}" }

    context 'when Basic Auth is not provided' do
      it 'returns an HTTP 401' do
        make_request
        last_response.status.should eq 401
      end
    end

    context 'when invalid Basic Auth is provided' do
      it 'returns an HTTP 401' do
        authorize 'badname', 'badpass'
        make_request
        last_response.status.should eq 401
      end
    end

    context 'when valid Basic Auth is provided' do
      before(:each) do
        authorize 'admin', 'admin'
        mock_mongodb_service_helper
      end

      context 'when the database resource already exists' do
        before(:each) do
          mongodb_srv_helper.should_receive(:database_exists?)
            .with(instance_id).and_return(true)
          mongodb_srv_helper.should_receive(:delete_database)
            .with(instance_id)
        end

        it 'returns an HTTP 200' do
          make_request
          last_response.status.should eq 200
        end

        it 'returns {} in the body' do
          make_request
          last_response.body.should eq '{}'
        end
      end

      context "when the database resource doesn't already exist" do
        it 'returns an HTTP 410' do
          mongodb_srv_helper.should_receive(:database_exists?)
            .with(instance_id).and_return(false)

          make_request
          last_response.status.should eq 410
        end
      end
    end
  end
end
