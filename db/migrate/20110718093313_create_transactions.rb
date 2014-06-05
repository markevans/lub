class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.date :date
      t.string :description
      t.integer :amount
      t.integer :balance
      t.string :signature

      t.timestamps
    end
  end
end
