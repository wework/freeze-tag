require 'rails'
require 'active_record'

module FreezeTag
  class Tag < ::ActiveRecord::Base
    self.table_name = "freeze_tags"
  end
end