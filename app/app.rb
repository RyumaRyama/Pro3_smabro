require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'socket'
require 'net/http'
require 'json'
require './models/data_init'
require 'uri'

require './helper.rb'
require './models/data_init'

# sessionを有効化
enable :sessions

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
  erb :top
  # redirect '/fighters'
end

get '/login' do
  p params[:code]
end

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
  if @fighter == "memo"
    redirect "/fighters/memo"
  else
    @fighter_memos = []
    client.exec_params("SELECT memo FROM notes WHERE fighter_id = $1",[params[:fighter_id]]).each do |memo|
      @fighter_memos << memo['memo']
    end
    erb :fighters_show
  end
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

get "/fighters/memo" do
  URL = URI.parse("https://www.googleapis.com/drive/v3/files/#{ENV['FILE_ID']}?alt=media&access_token=#{session[:access_token]}")
  begin
    redirect_url = Net::HTTP.get_response(URL)['location']
  rescue
    redirect "/"
  end
  response = Net::HTTP.get_response(URI.parse(redirect_url))
  session[:memo] = JSON.parse(response.body)
  @title = session[:memo]["title"]
  @memo = session[:memo]["cells"][0]["data"]
  
  erb :memo_show
end

def input_memo(memo)
  session[:memo]["cells"][0]["data"] = memo
end

post "/fighters/memo/update_memo" do
  input_memo(params[:memo])
  str = JSON.generate(session[:memo])

  postUrl = "https://www.googleapis.com/upload/drive/v3/files/#{ENV['FILE_ID']}?key=#{ENV['API_KEY']}"
  uri = URI.parse(postUrl)
  req = Net::HTTP::Patch.new(uri)
  req["Content-Type"] = "application/json"
  req["Accept"] = "application/json"
  req["Authorization"] = "Bearer #{session[:access_token]}"
  req.body = str

  req_options = {
    use_ssl: uri.scheme = "https"
  }

  begin
  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
	   http.request(req)
  end
  rescue
    redirect "/"
  end

  p "-"*100
  p response
  p "-"*100

  redirect "/fighters/memo"
end
