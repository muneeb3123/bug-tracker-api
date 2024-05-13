class ChangeDefaultDeveloperIdInBugs < ActiveRecord::Migration[7.1]
  def change
    change_column_default :bugs, :developer_id, nil
    remove_index :bugs, name: "index_bugs_on_developer_id"
  end
end
