class AlterPalletOneClickAccessesAddLanguageAndEmailNote < ActiveRecord::Migration
  def self.up
    add_column :pallet_one_click_accesses, :language, :string
    add_column :pallet_one_click_accesses, :email_notes, :string
  end

  def self.down
    remove_column :pallet_one_click_accesses, :language
    remove_column :pallet_one_click_accesses, :email_notes
  end
end
