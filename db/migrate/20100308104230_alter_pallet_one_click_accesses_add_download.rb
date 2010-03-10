class AlterPalletOneClickAccessesAddDownload < ActiveRecord::Migration
  def self.up
    add_column :pallet_one_click_accesses, :download, :string
  end

  def self.down
    remove_column :pallet_one_click_accesses, :download
  end
end
