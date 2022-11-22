class CreateTransformations < ActiveRecord::Migration[7.0]
  def change
    create_table :transformations do |t|
      t.string :name
      t.string :tr_string

      t.timestamps
    end
  end
end
