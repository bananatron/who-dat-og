require 'sinatra'
require 'firebase'
require 'json'
require 'digest'

require_relative 'helpers'

$base_uri = 'https://faces.firebaseio.com'
$fb_root = Firebase::Client.new($base_uri)

# configure :development do
#   set :bind, '0.0.0.0'
#   set :port, 3000
# end

#enable :sessions
#set :session_secret, $cookie_key

############$
## ROUTES #$
##########$

before do
  #@username = session['user'] if session['user']
end

#Get ROOT
get '/' do
  @employees = getNames('hired').to_json
  erb :index
end

#Get PLAY
get '/play' do
  if params[:name]
    @name = params[:name]
    @questions = generateTest()
    erb :play
  else
    redirect '/'
  end
end

#Get RESULTS
get '/results' do
  erb :results
end

get '/leaderboards' do
  redirect '/results'
end

#Get RESULTS
get '/about' do
  erb :about
end

#Get ADMIN
get '/admin' do
  erb :admin
end

#Post ADD
post '/add' do
  name = params[:name]
  position = params[:position]
  image = params[:image]
  
  addEmployee('hired', name, position, image)
  
  redirect '/admin'
end

#Weird shit
get '/lol' do 
  @varlol = params
  erb :playground
end

get '/sync' do 
  syncHiredEmployees
  redirect '/'
end


#Error 500
error 500 do
  erb :error
end