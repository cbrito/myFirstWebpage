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
  property :pageSlug,           String
  property :ownerName,          String
  property :secretWord,         String
  property :createdAt,          DateTime, :required => true,  :default => DateTime.now.new_offset(0), :writer => :private
  property :updatedAt,          DateTime, :required => true,  :default => DateTime.now.new_offset(0), :writer => :private
  
  property :title,      Text
  property :aboutMe,    Text
  
  property :bgImage, String
  property :bgColor, String
  property :font, String
  
  property :imageUrl,      Text
  property :faveThings, Text
  property :afterSchoolActivities, Text
  property :whatIWantToBe, Text
  
  
  #validates_uniqueness_of :secretWord, :message => ["Try a different secret word"]
end

DataMapper.auto_upgrade!

class WebpageServer < Sinatra::Base
  set :logging, true
  
  helpers do
    def to_slug(string)
      #strip the string
      ret = string.strip

      # Make sure we downcase
      ret.downcase!
      
      #blow away apostrophes
      ret.gsub! /['`]/,""

      # @ --> at, and & --> and
      ret.gsub! /\s*@\s*/, " at "
      ret.gsub! /\s*&\s*/, " and "

      #replace all non alphanumeric, underscore or periods with underscore
       ret.gsub! /\s*[^A-Za-z0-9\.\_]\s*/, '-'  

       #convert double underscores to single
       ret.gsub! /_+/,"-"

       #strip off leading/trailing underscore
       ret.gsub! /\A[-\.]+|[-\.]+\z/,""

       ret
    end

  end
  
  def build_page(page, params)
    page.title    = params['title']
    page.pageSlug = to_slug params['title']
    page.ownerName = params['ownerName']
    
    page.bgImage  = params['bgImage']
    page.bgColor  = params['bgColor']
    page.font     = params['font']
    
    page.aboutMe  = params['aboutMe']
    page.imageUrl = params['imageUrl']
    page.afterSchoolActivities = params['afterSchoolActivities']
    page.faveThings = params['faveThings']
    page.whatIWantToBe = params['whatIWantToBe']
  end
  
  get '/' do
    # TODO Create some sort of landing page
  end
  
  get '/pages' do
    @pages = Page.all
    erb :pages
  end
  
  get '/pages/new' do
    @page = Page.new({})
    erb :page
  end
  
  get '/pages/:id/edit' do
    @page = Page.first(:id => params[:id])
    erb :page
  end
  
  get '/pages/:id' do
    @page = Page.first(:id => params[:id])
    erb :_page_content
  end
  
  post '/pages/new' do
    page = Page.new
    build_page(page, params)
    if page.save
      redirect "/#{page.id}/#{page.pageSlug}"
#      redirect "/pages/#{page.id}"
    else
      @page.errors
    end
  end
  
  post '/pages/:id/edit' do
    page = Page.first(:id => params[:id])
    build_page(page, params)
    
    if page.save
      redirect "/#{page.id}/#{page.pageSlug}"
      #redirect "/pages/#{page.id}"
    else
      @page.errors
    end
  end
  
  get '/:id/:slug' do
    # Get a page based on slug-name
    @page = Page.last(:pageSlug => params[:slug])
    #redirect "/pages/#{@page.id}"
    erb :_page_content
  end
        
end #class WebpageServer