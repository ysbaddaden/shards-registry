class CreateUsers < Frost::Record::Migration
  set_version {{ __FILE__ }}

  up do
    create_table :users do |t|
      t.string :name,               null: false
      t.string :email,              null: false
      t.string :encrypted_password, null: false, limit: 60
      t.string :api_key,            null: false, limit: 43
      t.timestamps
    end

    add_index :users, :name,    unique: true
    add_index :users, :email,   unique: true
    add_index :users, :api_key, unique: true
  end

  down do
    drop_table :users
  end
end
