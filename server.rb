require 'rubygems'
require 'sinatra/base'

require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'


DataMapper.setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/development.sqlite")

# Database Methods
class Page
  include DataMapper::Resource
  
  property :id,              Serial
  property :secretWord,         String
  property :createdAt,          DateTime, :required => true,  :default => DateTime.now.new_offset(0), :writer => :private
  property :updatedAt,          DateTime, :required => true,  :default => DateTime.now.new_offset(0), :writer => :private
  
  property :title,      Text
  property :aboutMe,    Text
  
  #validates_uniqueness_of :secretWord, :message => ["Try a different secret word"]
end

DataMapper.auto_upgrade!

class WebpageServer < Sinatra::Base
  set :logging, true
  
  def build_page(page, params)
    page.title    = params['title']
    page.aboutMe  = params['aboutMe']
  end
    
  get '/pages' do
  end
  
  get '/pages/new' do
    @page = Page.new({})
    erb :page
  end
  
  get '/pages/:id' do
    @page = Page.first(:id => params[:id])
    erb :page
  end
  
  post '/pages/new' do
    page = Page.new(params)
    if page.save
      redirect "/pages/#{page.id}"
    else
      @page.errors
    end
  end
  
  put '/pages/:id/edit' do
    page = Page.first(:id => params[:id])
    build_page(page, params)
    
    if page.save
      redirect "/pages/#{page.id}"
    else
      @page.errors
    end
  end
        
end #class WebpageServer