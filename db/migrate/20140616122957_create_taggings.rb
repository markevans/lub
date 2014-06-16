class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.references :tag
      t.references :transaction
      t.timestamps
      t.index :tag_id
      t.index :transaction_id
    end
  end
end
