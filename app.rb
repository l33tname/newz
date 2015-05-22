require "sinatra"
require "bcrypt"
require_relative "model.rb"

use Rack::Session::Pool

helpers do
  def admin? ; session["isLogdIn"] == true; end
  #def admin? ; true; end
  def protected! ; halt 401 unless admin? ; end
end

configure :development do
  MongoMapper.database = 'newz'
end

configure :production do
	MongoMapper.setup({'production' => {'uri' => ENV['MONGOLAB_URI']}}, 'production')
end

get "/" do
	newz = Newz.sort(:created_at.desc).limit(30)
	erb :index, {:locals => {news: newz}}
end

get "/about" do
	erb :about
end

get "/submit" do
	"nope"
end

get "/archiv/?" do
	redirect "/archiv/1"
end

get "/archiv/:page/?" do |page|
	elementPerPage = 50
	pageId = page.to_i

	newz = Newz.paginate({
		:order => :created_at.desc,
		:per_page => elementPerPage,
		:page => pageId,
	})

	total = (Newz.all.count / elementPerPage)

	p total

	erb :archiv, {:locals => {page: pageId, news: newz, totalPage: total}}
end

post "/create" do
	protected!

	Newz.create(:title => params["title"], :url => params["url"])

	redirect "/"
end

get "/admin" do
	erb :admin
end

post "/admin" do
	logedIn = false
	name = params["inputUsername"]
	pass = params["inputPassword"]

	if name == ENV['USER'] && BCrypt::Engine.hash_secret(pass, ENV['SALT']) == ENV['PASS']
		session["isLogdIn"] = true
		redirect "/"
	end

	redirect "/admin"
end

get "/logout/?" do 
	session["isLogdIn"] = false
	redirect "/"
end
