require 'mongo'

class MongodbServiceHelper
  include Mongo

  attr_reader :mongodb_uri, :client

  def initialize(mongodb_uri)
    @mongodb_uri = mongodb_uri
  end

  def establish_connection
    @client = MongoClient.from_uri(mongodb_uri)
  end

  def database_exists?(name)
    client.database_names.include?(name)
  end
end
