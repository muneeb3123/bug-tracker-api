class AddDeveloperToBugs < ActiveRecord::Migration[7.1]
  def change
    add_reference :bugs, :developer, foreign_key: { to_table: :users }
  end
end
