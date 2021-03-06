require 'mongo'

class MongodbServiceHelper
  include Mongo

  attr_reader :mongodb_uri, :client

  def initialize(mongodb_uri)
    @mongodb_uri = mongodb_uri
  end

  def create_user(database, username, password)
    client[database].add_user(username, password)
  end

  def database_exists?(name)
    client.database_names.include?(name)
  end

  def delete_database(database)
    client.drop_database(database)
  end

  def delete_user(database, username)
    client[database].remove_user(username)
  end

  def establish_connection
    @client = MongoClient.from_uri(mongodb_uri)
  end

  def user_exists?(database, username)
    client[database]['system.users'].find(user: username).count >= 1
  end
end
