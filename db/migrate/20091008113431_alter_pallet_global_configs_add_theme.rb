class AlterPalletGlobalConfigsAddTheme < ActiveRecord::Migration
  def self.up
    add_column :pallet_global_configs, :theme, :string, :default => 'default'
  end

  def self.down
    remove_column :pallet_global_configs, :theme
  end
end
