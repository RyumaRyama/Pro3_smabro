require "sinatra"
require "sinatra/reloader"
require "mysql2"

# 一度だけ実行されるらしい
configure do
end

get "/" do
  fuga = ""
  client = connect_db_client
  client.query("SHOW TABLES").to_s
  client.query("SELECT * FROM users").each do |hoge|
    fuga += "<p>" + hoge["name"] + "</p>"
  end
  fuga
  # "Hello, from Docker. My Ruby version is: #{RUBY_VERSION}"
end

get "/hello" do
  "This is a new contents."
end

get "/akari" do
  '\ｱｯｶﾘ~ﾝ/ '*1000
end

def connect_db_client
  Mysql2::Client.new(
    host: "db",
    username: "root",
    password: "password",
    port: "3306",
    database: "db"
  )
end

