require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'socket'

p ENV["PORT"]
set :port, ENV["PORT"]

# dbのポートにアクセスできたらtrueを返す
def connecting_db
  begin
  TCPSocket.open(ENV['POSTGRES_HOST'], 5432)
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

p ENV['POSTGRES_HOST']
p ENV['POSTGRES_USER']
p ENV['POSTGRES_PASSWORD']
p ENV['POSTGRES_NAME']

client = PG::connect(
  host: ENV['POSTGRES_HOST'],
  user: ENV['POSTGRES_USER'],
  password: ENV['POSTGRES_PASSWORD'],
  port: '5432',
  dbname: ENV['POSTGRES_NAME']
)

# 一度だけ実行されるらしい
configure do
  client.exec("CREATE TABLE IF NOT EXISTS users (name TEXT);")
  # client.exec("INSERT INTO users (name) SELECT '\ｱｯｶﾘ~ﾝ/';")
  # client.exec("INSERT INTO users (name) SELECT 'Kyoko';")
  # client.exec("INSERT INTO users (name) SELECT 'Yui';")
  # client.exec("INSERT INTO users (name) SELECT 'Chinatsu';")
end

get '/' do
  # '\ｱｯｶﾘ~ﾝ/ '*100
  client.exec("INSERT INTO users (name) SELECT '\\ｱｯｶﾘ~ﾝ/';")
  fuga = ''
  client.query('SELECT * FROM users').each do |hoge|
    fuga += hoge['name'] + " "
  end
  fuga
end

get '/hello' do
  'This is a new contents.' end


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
