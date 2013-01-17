require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require './models'

get '/' do
	"hello"
end

get '/edition' do
	@piece = Piece.first :delivery_order => params[:delivery_count].to_i
	etag @piece.delivery_order
	erb :edition
end

get '/sample' do
end

get '/all' do
	@pieces = Piece.all
	erb :all
end

post "/validate_config" do
  if ["original", "recode"].include? params["edition_type"]
  	"{\"valid\" : true}"
  else
  	"{\"valid\": false, \"errors\": [\"Please select a ReCodePrinter edition.\"]}"
  end
end