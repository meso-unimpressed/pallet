class AlterPalletOneClickAccessesRemoveComment < ActiveRecord::Migration
  def self.up
    remove_column :pallet_one_click_accesses, :comment
  end

  def self.down
    add_column :pallet_one_click_accesses, :comment, :string
  end
end
