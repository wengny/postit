class CreateCategory < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.integer :name
    end
  end
end
