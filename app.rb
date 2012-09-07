## Library Imports
require 'rubygems' # Needed to import all other libraries
require 'sinatra' # Web framework we are using
require 'data_mapper' # Needed to abstract SQLite access

delimChar = '|' # Our delimiter for sending records across the server

## Configuration Options

# Look up templates for the template engine in the '/templates'
# subdirectory
set :views, settings.root + '/templates'

# Make sure that files marked static are cached.
# Static files are files that do not change (like Javascript code
# or CSS) and so caching them in browser is more efficient
set :static_cache_control, true

# Make sure that Sinatra serves up files located in the '/public'
# subdirectory as static
set :static, true

# DataMapper is an abstract interface to our SQLite db.
# Make sure that it uses the local file named 'test.db'
DataMapper.setup(:default, "sqlite3:test.db")


## Model Definitions

# Our data is stored in terms of a class
# called NameTimeData
# NameTimeData contains two fields:
# Name: A string which contains the username
# Time: An integer which contains the timestamp
#
# DataMapper stores this inside the test.db
# file as a table named 'name_time_data'
class NameTimeData
  include DataMapper::Resource

  property :name, String, :key => true
  property :time, Integer
end

DataMapper.finalize # Finish the model initialization

# Erase or update tables with the same name in our
# db
NameTimeData.auto_migrate!

## Route definitions

# The default URL handler calls erb to render
# a template 
# All templates are found in the 'templates'
# subdirectory
get '/' do
  # This renders 'templates/user_prompt.erb'
  erb :user_prompt
end

# This is the AJAX POST handler
# It checks if a name is given
# if the name is given, then the name and the current time
# are stored into the database, and then the name and
# current time are returned to the browser in the form
# "name|currentTime" with '|' acting as a delimiter character
post '/givename' do
  if params['name'] # If the 'name' parameter is valid
    currTime = Time.now.to_i # Store the current time
    # Create an instance of our db data
    data = NameTimeData.new name: params['name'], time: currTime 
    data.save # Save the db data to our database

    # Return the concatenation of the 'name' paramater,
    # the delimChar which is '|', and a string representation
    # of the current time
    params['name']+delimChar+currTime.to_s

  else # If it is not valid, then return 'error'
    'error'
  end
end
