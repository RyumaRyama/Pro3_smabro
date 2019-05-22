require 'sinatra'
require 'sinatra/reloader'
require 'mysql2'
require 'socket'

# dbのポートにアクセスできたらtrueを返す
def connecting_db
  begin
  TCPSocket.open('db', 3306)
  rescue
    false
  else
    true
  end
end

# dbに繋げられる状態まで1秒ずつ待つ
while !connecting_db
  sleep 1
end

client = Mysql2::Client.new(
  host: 'db',
  username: 'root',
  password: 'password',
  port: '3306',
  database: 'db'
)

# 一度だけ実行されるらしい
configure do
end

get '/' do
  fuga = ''
  client.query('SELECT * FROM fighters').each do |hoge|
    fuga += '<p>' + hoge['id'].to_s + ":" + hoge['name'] + '</p>'
  end
  fuga
  # 'Hello, from Docker. My Ruby version is: #{RUBY_VERSION}'
end

get '/hello' do
  'This is a new contents.'
end


get "/gorakubu/akari" do
  '\ｱｯｶﾘ~ﾝ/ '*1000
end

get "/gorakubu/kyoko" do
  '\ｷｭｯﾋﾟ~ﾝ/ '*1000
end

get "/gorakubu/yui" do
  '\ｵｲｺﾗ/ '*1000
end

get "/gorakubu/chinatsu" do
  '\ｾﾝﾊﾟ~ｲ/ '*1000
end

get "/gorakubu" do
  @users = ["akari", "kyoko", "yui", "chinatsu"]
  erb :gorakubu
end
