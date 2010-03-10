class AlterPalletOneClickAccessesAddUserId < ActiveRecord::Migration
  def self.up
    add_column :pallet_one_click_accesses, :user_id, :integer
  end

  def self.down
    remove_column :pallet_one_click_accesses, :user_id
  end
end
