require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'socket'
#require 'json'
require './models/data_init'
require 'erb'

begin
  client = PG::connect(
    host: ENV['POSTGRES_HOST'],
    user: ENV['POSTGRES_USER'],
    password: ENV['POSTGRES_PASSWORD'],
    port: '5432',
    dbname: ENV['POSTGRES_NAME']
  )
rescue
  sleep 1
  retry
end

# 一度だけ実行されるらしい
configure do
  init_db(client)
  insert_fighters(client)
end

get '/' do
  @fighters = []
  client.query('SELECT * FROM fighters').each do |data|
    @fighters << data
  end
  erb :top
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

get "/:fighter_id" do
  # insert_fighters_memo(client,params[:fighter_id])
  @fighter = client.exec("SELECT name FROM fighters WHERE id = #{params[:fighter_id]}")[0]["name"]
  @fighter_memos = []
  client.exec("SELECT memo FROM notes WHERE fighter_id = #{params[:fighter_id]}").each do |memo|
    @fighter_memos << memo['memo']
  end
  erb :fighters_show
end

post "/:fighter_id/add_memo" do
  memo = params[:memo]
  insert_fighters_memo(client,params[:fighter_id],memo)
  redirect  "/#{params[:fighter_id]}"
end

get "/test_api/:fighter" do
  content_type :json
  # fighterの存在確認
  count_sql = "SELECT COUNT(*) AS count FROM fighters \
                WHERE name = '#{params[:fighter]}'"
  fighter_num = client.exec(count_sql)[0]["count"].to_i

  if fighter_num > 0
    return_data = {"result": true, "message": "OK"}
    sql = "SELECT notes.memo FROM notes \
            INNER JOIN fighters \
            ON notes.fighter_id = fighters.id \
            WHERE fighters.name = '#{params[:fighter]}'"
    fighter_memos = []
    client.exec(sql).each do |memo|
      fighter_memos << memo['memo']
    end
    return_data.store("memos", fighter_memos)
  else
    return_data = {"result": false, "message": "ERROR: no data."}
  end

  return_data.to_json
end

get '/test/new' do
  erb :new
end

post '/test/create' do
  sql = "INSERT INTO players (id, name, lineid, password) \
  VALUES(#{params[:id]},'#{params[:name]}', '#{params[:lineid]}', '#{params[:password]}')"
  client.exec(sql)
  redirect  "test/players/#{params[:id]}"
end

get '/test/players/:id' do
  @player = client.query("SELECT * FROM players WHERE id = #{params[:id]}")[0]
  erb :player
end
