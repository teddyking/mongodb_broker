require 'active_support/concern'

module Helpers
  extend ActiveSupport::Concern

  included do
    let(:uri)               { 'mongodb://localhost:27017' }
    let(:mongo_srv_helper)  { MongodbServiceHelper.new(uri) }
    let(:test_conn)         { double('Mongo::MongoClient') }
    let(:test_db)           { double('Mongo::DB') }
    let(:test_coll)         { double('Mongo::Collection') }
    let(:test_cursor)       { double('Mongo::Cursor') }

    let(:instance_id)         { '1234-abcd-12cd' }
    let(:binding_id)          { 'abcd-1234-ab34' }
    let(:mongodb_srv_helper)  { double('MongodbServiceHelper') }
  end

  def mock_connect_to_mongo
    Mongo::MongoClient.should_receive(:from_uri).with(uri)
      .and_return(test_conn)

    mongo_srv_helper.establish_connection
  end

  def mock_select_database(name)
    test_conn.should_receive(:[]).with(name).and_return(test_db)
  end

  def mock_select_collection(name)
    test_db.should_receive(:[]).with(name).and_return(test_coll)
  end

  def mock_mongodb_service_helper
    MongodbServiceHelper.should_receive(:new)
      .and_return(mongodb_srv_helper)
    mongodb_srv_helper.should_receive(:establish_connection)
  end
end
