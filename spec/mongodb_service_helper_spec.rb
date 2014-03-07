require_relative './spec_helper'

describe MongodbServiceHelper do

  describe '#establish_connection' do
    it 'connects to MongoDB using a uri' do
      Mongo::MongoClient.should_receive(:from_uri).with(uri)

      mongo_srv_helper.establish_connection
    end
  end

  describe '#database_exists?' do
    before(:each) do
      mock_connect_to_mongo
    end

    context 'when the named database already exists' do
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

  describe '#create_user' do
    before(:each) do
      mock_connect_to_mongo
    end

    it 'creates a user on the database' do
      mock_select_database('test')
      test_db.should_receive(:add_user).with('test', 'test')

      mongo_srv_helper.create_user('test', 'test', 'test')
    end
  end

  describe '#user_exists?' do
    before(:each) do
      mock_connect_to_mongo
      mock_select_database('test')
      mock_select_collection('system.users')
      test_coll.should_receive(:find).with(user: 'test')
        .and_return(test_cursor)
    end

    context 'when the user does exist' do
      it 'returns true' do
        test_cursor.should_receive(:count).and_return(1)

        mongo_srv_helper.user_exists?('test', 'test').should eq true
      end
    end

    context "when the user doesn't exist" do
      it 'returns false' do
        test_cursor.should_receive(:count).and_return(0)

        mongo_srv_helper.user_exists?('test', 'test').should eq false
      end
    end
  end
end
