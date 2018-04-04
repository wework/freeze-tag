ActiveRecord::Schema.define do
  self.verbose = false

  create_table :freeze_tags do |t|
    t.string   :taggable_type, index: true, null: false
    t.string   :tag,           index: true, null: false
    t.integer  :taggable_id,   index: true, null: false
    t.datetime :ended_at,      index: true
    t.timestamps
  end

  add_index :freeze_tags, [:taggable_type, :taggable_id, :tag], unique: true

  create_table :articles do |t|
    t.string :title
    t.string :body
  end

end