require 'rubygems'
require 'bundler/setup'
require 'json'
require 'dm-aggregates'
require 'dm-core'
require 'dm-migrations'
require 'dm-types'
require 'httparty'
require 'open-uri'
require 'date'
require 'bitly_oauth'

DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_ROSE_URL'] || 'postgres://localhost/recode_printer')

RECODE_DATA_URL = "http://recodeproject.com/data"

class Piece
  include DataMapper::Resource

  property :id, Serial
  property :delivery_order, Integer

  property :original_piece_id, String
  property :title, Text
  property :artist, Text
  property :year, Integer
  property :original_image_url, Text
  property :original_piece_url, Text
  property :shortened_piece_url, Text

  property :recoder, Text
  property :recode_image_url, Text
  property :recode_source_code, Text
  property :recode_id, String
  property :recode_created_at, DateTime
  property :recode_url, Text
  property :shortened_recode_url, Text


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
  			:original_image_url => recoded["orig_img_url"],
        :original_piece_id => recoded["id"],
        :original_piece_url => recoded["static_url"],


  			:recoder => recoded["recodes"][0]["author"],
        :recode_url => recoded["recodes"][0]["static_url"],
  			:recode_image_url => recoded["recodes"][0]["recode_img_url"],
  			:recode_source_code => open(recoded["recodes"][0]["pde_link"]).read,
        :recode_id => recoded["recodes"][0]["id"],
        :recode_created_at => DateTime.parse(recoded["recodes"][0]["timestamp"]),

  			:delivery_order => i
  		)

  		i = i +1
  	end
  end

  def self.shorten_links!
  client = BitlyOAuth.new ENV['BITLY_CLIENT_ID'], ENV['BITLY_CLIENT_SECRET']
  client.set_access_token_from_token ENV['BITLY_TOKEN']
  
  Piece.all(:shortened_piece_url => nil).each do |p|
    p.shortened_piece_url = client.shorten(p.original_piece_url).short_url
    p.save
  end

  Piece.all(:shortened_recode_url => nil).each do |p|
    p.shortened_recode_url = client.shorten(p.recode_url).short_url
    p.save
  end

end

end



DataMapper.finalize
