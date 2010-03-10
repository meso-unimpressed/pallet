class CreatePalletGlobalConfigs < ActiveRecord::Migration
  def self.up
    create_table :pallet_global_configs, :options => 'ENGINE=MyISAM CHARACTER SET utf8 COLLATE utf8_general_ci' do |t|
      t.string  :root_path
      t.string  :domain
      t.string  :email_robot_address
      t.integer :max_upload_file_size, :default => 100 # MB
      t.timestamps
    end

    PalletGlobalConfig.new(:root_path => 'pallet_container').save
  end

  def self.down
    drop_table :pallet_global_configs
  end
end
