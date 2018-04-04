require 'active_record'
require 'action_controller'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

require_relative '../db/schema'
require_relative './models/article'