require "sinatra"
require "sinatra/reloader"
require "mysql2"

get "/" do
  hoge
  "Hello, from Docker. My Ruby version is: #{RUBY_VERSION}"
end

get "/hello" do
  "This is a new contents."
end

get "/akari" do
  '\ｱｯｶﾘ~ﾝ/ '*1000
end

def hoge
  client = Mysql2::Client.new(
    host: "db",
    username: "root",
    password: "password",
    port: "3306",
    database: "database"
  )
  p client.query("SHOW TABLES")
end
