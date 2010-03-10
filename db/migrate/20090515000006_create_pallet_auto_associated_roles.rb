class CreatePalletAutoAssociatedRoles < ActiveRecord::Migration
  def self.up
    create_table "pallet_auto_associated_roles", :options => 'ENGINE=MyISAM CHARACTER SET utf8 COLLATE utf8_general_ci' do |t|
      t.string :role_id
    end 
  end

  def self.down
    drop_table "pallet_auto_associated_roles"
  end
end
