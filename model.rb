require "mongo_mapper"

class Newz
	include MongoMapper::Document

	key :title, String, :required => true
	key :url, String, :required => true

	timestamps!
end