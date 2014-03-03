require_relative './spec_helper'

describe MongodbServiceHelper do
  let(:uri)              { 'mongodb://localhost:27017' }
  let(:mongo_srv_helper) { MongodbServiceHelper.new(uri) }
  let(:test_conn)        { double("Mongo::MongoClient") }

  describe '#establish_connection' do
    it 'connects to MongoDB using a uri' do
      uri = 'mongodb://localhost:27017'

      Mongo::MongoClient.should_receive(:from_uri).with(uri)
      mongo_srv_helper = MongodbServiceHelper.new(uri)
      mongo_srv_helper.establish_connection
    end
  end

  describe 'database_exists?' do
    before(:each) do
      Mongo::MongoClient.should_receive(:from_uri).with(uri).
        and_return(test_conn)
      mongo_srv_helper.establish_connection
    end
    
    context "when the named database already exists" do
      it 'returns true' do
        test_conn.should_receive(:database_names).and_return([])

        mongo_srv_helper.database_exists?('my_db').should eq false
      end
    end

    context "when the named database doesn't exist" do
      it 'returns false' do
        test_conn.should_receive(:database_names).and_return(['my_db'])

        mongo_srv_helper.database_exists?('my_db').should eq true
      end
    end
  end
end
