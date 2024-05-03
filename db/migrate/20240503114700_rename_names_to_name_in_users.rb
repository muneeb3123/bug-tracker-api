class RenameNamesToNameInUsers < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :names, :name
  end
end
