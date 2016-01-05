class CreateShards < Frost::Record::Migration
  set_version {{ __FILE__ }}

  up do
    create_table :shards do |t|
      t.integer :user_id, null: false
      t.string  :name,    null: false, limit: 50
      t.string  :url,     null: false
      t.timestamps
    end

    add_index :shards, :user_id
    add_index :shards, :name, unique: true
  end

  down do
    drop_table :shards
  end
end
