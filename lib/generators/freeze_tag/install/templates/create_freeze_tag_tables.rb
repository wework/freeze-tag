class CreateFreezeTagTables < ActiveRecord::Migration
  def change
    
    raise "Please, make sure you've configured this correctly. Then remove this happy little warning :-)"

    create_table :freeze_tags do |t|
      t.string  :taggable_type,  index: true, null: false
      t.string  :tag,            index: true, null: false
      t.string  :list,           index: true
      # t.uuid    :taggable_id,   index: true, null: false # Use this if you're mapping using UUIDs as a primary key
      # t.integer :taggable_id,   index: true, null: false # Use this if you're mapping using Integer Primary Keys
      t.datetime  :ended_at,     index: true
      t.timestamps
    end

    add_index :freeze_tags, [:taggable_type, :taggable_id, :tag, :ended_at]
    add_index :freeze_tags, [:taggable_type, :taggable_id, :ended_at]
    add_index :freeze_tags, [:tag, :ended_at]    
    add_index :freeze_tags, [:taggable_type, :taggable_id, :tag, :list], unique: true, name: "unique"
  end
end 