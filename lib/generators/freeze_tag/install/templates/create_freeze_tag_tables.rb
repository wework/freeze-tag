class CreateFreezeTagTables < ActiveRecord::Migration

  # TODO: You may experience the following error: 
  # Directly inheriting from ActiveRecord::Migration is not supported. 
  # Please specify the Rails release the migration was written for.
  # If so, change the rails version to like: 
  # class CreateFreezeTagTables < ActiveRecord::Migration[5.1]
  # to your file

  def change
    
    raise "Please, make sure you've configured this correctly. Then remove this happy little warning :-)"

    create_table :freeze_tags do |t|
      t.string  :taggable_type,  index: true, null: false
      t.string  :tag,            index: true, null: false
      t.string  :list,           index: true
      # t.uuid    :taggable_id,   index: true, null: false # Use this if you're mapping using UUIDs as a primary key
      # t.integer :taggable_id,   index: true, null: false # Use this if you're mapping using Integer Primary Keys
      t.datetime  :expired_at,   index: true
      t.timestamps
    end

    add_index :freeze_tags, [:taggable_type, :taggable_id, :tag, :expired_at, :list], name: "ft_tt_tid_t_exp_list"
    add_index :freeze_tags, [:taggable_type, :taggable_id, :expired_at, :list], name: "ft_tt_tid_exp_list"
    add_index :freeze_tags, [:tag, :expired_at, :list]
    add_index :freeze_tags, [:taggable_type, :taggable_id, :tag, :list, :expired_at], unique: true, name: "fz_unique_tt_tid_t_li_ex_at"
  end
end 