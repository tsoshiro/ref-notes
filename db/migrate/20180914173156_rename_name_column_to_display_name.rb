class RenameNameColumnToDisplayName < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :name, :display_name
    rename_column :users, :canonical_name, :user_name
  end
end
