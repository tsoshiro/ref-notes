class AddCanonicalNameToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :canonical_name, :string
  end
end
