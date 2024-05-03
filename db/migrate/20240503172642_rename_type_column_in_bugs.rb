class RenameTypeColumnInBugs < ActiveRecord::Migration[7.1]
  def change
    rename_column :bugs, :type, :bug_type
  end
end
