class Article < ActiveRecord::Base
  include FreezeTag::Taggable
end
