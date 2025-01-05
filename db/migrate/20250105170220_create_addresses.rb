class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :city
      t.string :postal_code
      t.string :country

      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
