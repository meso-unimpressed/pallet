class CreateSessionLogs < ActiveRecord::Migration
  def self.up
    create_table :session_logs, :options => 'ENGINE=MyISAM CHARACTER SET utf8 COLLATE utf8_general_ci' do |t|
      t.references :user
      t.timestamp :logged_in_at
      t.timestamp :logged_out_at
    end
  end

  def self.down
    drop_table :session_logs
  end
end
