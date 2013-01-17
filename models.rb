require 'rubygems'
require 'bundler/setup'
require 'json'
require 'dm-aggregates'
require 'dm-core'
require 'dm-migrations'
require 'dm-types'
require 'httparty'
require 'open-uri'

DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_BLUE_URL'] || 'postgres://localhost/recode_printer')

RECODE_DATA_URL = "http://recodeproject.com/data"

class Piece
  include DataMapper::Resource

  property :id, Serial
  property :delivery_order, Integer

  property :title, Text
  property :artist, Text
  property :year, Integer
  property :original_piece_url, Text

  property :recoder, Text
  property :recode_image_url, Text
  property :recode_source_code, Text

  def self.import_from_json!
  	json = open(RECODE_DATA_URL).read
  	result = JSON.parse(json)


  	i = 1
  	result["artworks"].select{|a| a["recodes"]}.each do |recoded|
  		next unless recoded["recodes"].length > 0

  		Piece.create(
  			:title => recoded["title"],
  			:artist => recoded["artist"],
  			:year => recoded["year"].to_i,
  			:original_piece_url => recoded["orig_img_url"],

  			:recoder => recoded["recodes"][0]["author"],
  			:recode_image_url => recoded["recodes"][0]["recode_img_url"],
  			:recode_source_code => open(recoded["recodes"][0]["pde_link"]).read,

  			:delivery_order => i+1
  		)

  		i = i +1
  	end
  end

end

DataMapper.finalize
