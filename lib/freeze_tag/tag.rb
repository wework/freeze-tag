require 'rails'
require 'active_record'

module FreezeTag
  class Tag < ::ActiveRecord::Base
    self.table_name = "freeze_tags"
    belongs_to :taggable, polymorphic: true

    def expired?
      expired_at > DateTime.now
    end

  end
end