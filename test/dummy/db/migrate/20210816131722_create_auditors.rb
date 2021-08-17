class CreateAuditors < ActiveRecord::Migration[7.0]
  def change
    create_table :auditors do |t|
      t.string :name

      t.timestamps
    end
  end
end
