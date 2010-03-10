class CreatePallets < ActiveRecord::Migration
  def self.up
    create_table :pallets, :options => 'ENGINE=MyISAM CHARACTER SET utf8 COLLATE utf8_general_ci' do |t|
      t.string  :name
      t.string  :directory
      t.string  :description
      t.string  :file_types, :default => '*'
      t.boolean :one_click_access_generation_by_users
      t.boolean :is_readonly

      t.timestamps
    end
  end

  def self.down
    drop_table :pallets
  end
end
