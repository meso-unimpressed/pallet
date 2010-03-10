class AlterPalletsRenameCreator < ActiveRecord::Migration
  def self.up
    add_column :pallets, :user_id, :integer

    Pallet.find(:all).each do |pallet|
      user = User.find_by_login pallet.creator
      if user
        puts pallet.creator + ' -> ' + user.id.to_s
        pallet.update_attribute('user_id', user.id)
      end
    end

    remove_column :pallets, :creator
  end

  def self.down
    add_column :pallets, :creator, :string

    Pallet.find(:all).each do |pallet|
      user = User.find_by_id pallet.user_id
      if user
        puts pallet.user.id.to_s + ' -> ' + user.login
        pallet.update_attribute('creator', user.login)
      end
    end

    remove_column :pallets, :user_id
  end
end
