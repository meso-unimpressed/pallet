class AlterSessionLogsAddPalletId < ActiveRecord::Migration
  def self.up
    add_column :session_logs, :pallet_id, :integer
  end

  def self.down
    remove_column :session_logs, :pallet_id
  end
end
