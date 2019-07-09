require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'socket'
#require 'json'
require './helper.rb'
require './models/data_init'

enable :sessions
use Rack::Session::Cookie, :key => :user_id,
                           :expire_after => 600,
                           :secret => Digest::SHA256.hexdigest(rand.to_s)
# use Rack::Session::Cookie, :key => 'rack.session',
#                            :expire_after => 600,
#                            :secret => Digest::SHA256.hexdigest(rand.to_s)

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

lineid = "hoge"

# 一度だけ実行されるらしい
configure do
  init_db(client)
  insert_fighters(client)
end

get '/linebot' do
  # session[:user_id]
  session[:user_id] = nil
  lineid
end

post '/linebot' do
  content_type :json
  data = JSON.parse(request.body.read)
  lineid = data["lineid"]
  # session[:user_id] = data["lineid"]
  session[:user_id] = "hogehogehoge"
end

get '/' do
  # if logged_in?
  #   redirect '/fighters'
  # end
  # erb :top
  redirect '/fighters'
end

# post '/login' do
#   session[:user_id] = "hoge"
#   redirect '/'
# end

get '/fighters' do
  @fighters = []
  client.query('SELECT * FROM fighters').each do |data|
    @fighters << data
  end
  session[:user_id] = "none"
  erb :fighters_index
end

get "/:fighter_id" do
  # insert_fighters_memo(client,params[:fighter_id])
  @fighter = client.exec_params("SELECT name FROM fighters WHERE id = $1",[params[:fighter_id]])[0]["name"]
  @fighter_memos = []
  client.exec_params("SELECT memo FROM notes WHERE fighter_id = $1",[params[:fighter_id]]).each do |memo|
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
                WHERE name = $1"
  fighter_num = client.exec_params(count_sql,[params[:fighter]])[0]["count"].to_i

  if fighter_num > 0
    return_data = {"result": true, "message": "OK"}
    sql = "SELECT notes.memo FROM notes \
            INNER JOIN fighters \
            ON notes.fighter_id = fighters.id \
            WHERE fighters.name = $1"
    fighter_memos = []
    client.exec_params(sql,[params[:fighter]]).each do |memo|
      fighter_memos << memo['memo']
    end
    return_data.store("memos", fighter_memos)
  else
    return_data = {"result": false, "message": "ERROR: no data."}
  end

  return_data.to_json
end

def text_plane(text)
  Rack::Utils.escape_html(text)
end

get '/test/linelogins' do
  params[:code]
end

get '/test/callback' do
  content_type :json
  data = JSON.parse(request.body.read)
  data["access_token"]
end
