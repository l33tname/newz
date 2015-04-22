require "mongo_mapper"

class Newz
	include MongoMapper::Document

	key :title, String, :required => true
	key :url, String, :required => true

	timestamps!

	def url_short length
		short = url[0..length]
		short += "..." if url.length > length
		short
	end
end