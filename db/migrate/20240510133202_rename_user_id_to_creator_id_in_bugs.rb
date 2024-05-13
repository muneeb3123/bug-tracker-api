class RenameUserIdToCreatorIdInBugs < ActiveRecord::Migration[7.1]
  def change
    rename_column :bugs, :user_id, :creator_id
  end
end
