class CreateVersions < Frost::Record::Migration
  set_version {{ __FILE__ }}

  up do
    create_table :versions do |t|
      t.integer  :shard_id,    null: false
      t.string   :number,      null: false
      t.datetime :released_at
      t.string   :description
      t.string   :license
     #t.json     :authors,                  default: "{}"
     #t.json     :dependencies,             default: "{}"
     #t.json     :development_dependencies, default: "{}"
      t.text     :readme
    end

    add_index :versions, {:shard_id, :number}, unique: true
  end

  down do
    drop_table :versions
  end
end
