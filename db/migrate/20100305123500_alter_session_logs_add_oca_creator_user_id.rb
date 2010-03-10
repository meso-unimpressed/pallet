class AlterSessionLogsAddOcaCreatorUserId < ActiveRecord::Migration
  def self.up
    add_column :session_logs, :oca_creator_user_id, :integer
  end

  def self.down
    remove_column :session_logs, :oca_creator_user_id
  end
end
