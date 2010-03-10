class CreatePalletsRoles < ActiveRecord::Migration
  def self.up
    # do NOT use ID columns for join tables => http://forum.ruby-portal.de/viewtopic.php?p=22399
    create_table :pallets_roles, :options => 'ENGINE=MyISAM CHARACTER SET utf8 COLLATE utf8_general_ci',
                 :id => false do |t|
      t.integer :pallet_id
      t.integer :role_id
    end
  end

  def self.down
    drop_table :pallets_roles
  end
end
