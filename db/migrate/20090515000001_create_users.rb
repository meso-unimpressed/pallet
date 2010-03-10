class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true, :options => 'ENGINE=MyISAM CHARACTER SET utf8 COLLATE utf8_general_ci' do |t|
      t.string :login,             :null => false
      t.string :email,             :default => ''
      t.string :crypted_password,  :null => false
      t.string :password_salt,     :null => false
      t.string :persistence_token, :null => false

      # ldap flag
      t.boolean :ldap_auth, :default => false
      # user full name
      t.string :name, :default => ''

      # optional automagically filled fields. see Authlogic::Session::MagicColumns
      t.integer  :login_count,        :null => false, :default => 0
      t.integer  :failed_login_count, :null => false, :default => 0
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      
      # uncommented due to possible legal issues (ip logging!)
      #t.string   :current_login_ip
      #t.string   :last_login_ip
      
      t.timestamps
    end

    add_index :users, :login
    add_index :users, :persistence_token
    add_index :users, :last_request_at
  end


  def self.down
    drop_table :users
  end
end
