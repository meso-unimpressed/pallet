class CreateRolesUsers < ActiveRecord::Migration
  def self.up
    create_table :roles_users, :force => true, :options => 'ENGINE=MyISAM CHARACTER SET utf8 COLLATE utf8_general_ci' do |t|
      t.references :role
      t.references :user
    end
  end

  def self.down
    drop_table :roles
  end
end
