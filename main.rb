require 'rubygems'
require 'sinatra'

#set :sessions, true

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'yjdfh432'

get '/test' do
  erb :test
end

get "/nested" do
  erb :"nested/temp"
end



