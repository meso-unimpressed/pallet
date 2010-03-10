class AlterPalletAddCreator < ActiveRecord::Migration
  def self.up
    add_column :pallets, :creator, :string
  end

  def self.down
    remove_column :pallets, :creator
  end
end
