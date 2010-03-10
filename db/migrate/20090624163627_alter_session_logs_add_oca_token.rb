class AlterSessionLogsAddOcaToken < ActiveRecord::Migration
  def self.up
    add_column :session_logs, :oca_token, :string
  end

  def self.down
    remove_column :session_logs, :oca_token
  end
end
