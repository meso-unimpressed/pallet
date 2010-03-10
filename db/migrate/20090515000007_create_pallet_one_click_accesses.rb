class CreatePalletOneClickAccesses < ActiveRecord::Migration
  def self.up
    create_table "pallet_one_click_accesses", :force => true, :options => 'ENGINE=MyISAM CHARACTER SET utf8 COLLATE utf8_general_ci' do |t|
      t.integer   :pallet_id
      t.string    :sub_path
      t.string    :token
      t.string    :comment
      t.text      :email_receivers
      t.datetime  :expires_at
      t.datetime  :created_at
    end 
  end

  def self.down
    drop_table "pallet_one_click_accesses"
  end
end
