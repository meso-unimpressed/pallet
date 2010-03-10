class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles, :force => true, :options => 'ENGINE=MyISAM CHARACTER SET utf8 COLLATE utf8_general_ci' do |t|
      t.integer :parent_id
      t.string :title
      t.string :description
    end
    
    # Load initial data from fixtures
    require 'active_record/fixtures'
    dir = File.join(File.dirname(__FILE__), "data")
    Fixtures.create_fixtures(dir, "roles")
  end

  def self.down
    drop_table :roles
  end
end
