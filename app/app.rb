require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'socket'
require 'net/http'
require 'json'
require './models/data_init'
require 'uri'


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
  @fighter = client.exec_params("SELECT name FROM fighters WHERE id = $1",[params[:fighter_id]])[0]["name"]
  if @fighter == "memo"
    redirect "/test/googledrive"
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

get "/test/googledrive" do
  URL = URI.parse("https://www.googleapis.com/drive/v3/files/#{ENV['FILE_ID']}?alt=media&access_token=アクセストークン")
  redirect_url = Net::HTTP.get_response(URL)['location']
  p redirect_url
  response = Net::HTTP.get_response(URI.parse(redirect_url))
  hash = JSON.parse(response.body)
  #p hash["title"]
  @title = hash["title"]
  hash["title"] = "タイトリ"
  str = JSON.generate(hash)


  postUrl = "https://www.googleapis.com/upload/drive/v3/files/1G0P3Jv5qYkuZ7e5FUmcQmekUXoqu1ZP_?key=#{ENV['API_KEY']}"
  uri = URI.parse(postUrl)
  req = Net::HTTP::Patch.new(uri)
  req["Content-Type"] = "application/json"
  req["Accept"] = "application/json"
  req["Authorization"] = "Bearer アクセストークン"
  req.body = str


  req_options = {
    use_ssl: uri.scheme = "https"
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
	   http.request(req)
  end

  p response
end
