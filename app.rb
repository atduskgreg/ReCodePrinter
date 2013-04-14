require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require './models'

	get '/' do
		erb :index
	end

	get '/edition/' do
		delivery = 2
		if params[:delivery_count]
			delivery = params[:delivery_count].to_i
		end
	
		@piece = Piece.first :delivery_order => delivery
		etag @piece.delivery_order
		erb :edition
	end
	
	get '/sample/' do
		@piece = Piece.first :delivery_order => 3
		etag "sample#{@piece.delivery_order}"
		erb :edition
	end
	
	get '/all' do
		@pieces = Piece.all
		erb :all
	end
	
	post "/validate_config/" do
	  if ["original", "recode"].include? params["edition_type"]
	  	"{\"valid\" : true}"
	  else
	  	"{\"valid\": false, \"errors\": [\"Please select a ReCodePrinter edition.\"]}"
	  end
	end

