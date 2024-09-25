class CreateTopicCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :topic_categories do |t|
      t.integer :partner_id
      t.string :name
      t.string :subscript
      t.text :description
      t.integer :display_order
      t.string :content_type
      t.string :display_style
      t.text :movie_url
      t.string :menu_name

      t.integer :disclose_flg

      t.timestamps
    end
  end
end
