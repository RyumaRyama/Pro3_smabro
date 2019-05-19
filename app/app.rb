require "sinatra"
require "sinatra/reloader"

get "/" do
  "Hello, from Docker. My Ruby version is: #{RUBY_VERSION}"
end

get "/hello" do
  "This is a new contents."
end

get "/akari" do
  '\ｱｯｶﾘ~ﾝ/ '*1000
end

get "/gorakubu" do
  @users = ["akari", "kyoko", "yui", "chinatsu"]
  erb :gorakubu
end
