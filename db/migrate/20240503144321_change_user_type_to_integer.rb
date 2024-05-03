class ChangeUserTypeToInteger < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :user_type, 'integer USING CAST(user_type AS integer)'
  end
end
