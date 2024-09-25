class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.integer :partner_id
      t.text :category

      t.string :title
      t.text :description
      t.string :index_type

      t.text :movie_url

      t.string :item1_label
      t.text :item1_content
      t.string :item1_position
      t.string :item1_image_alt
      t.text :item1_movie_url

      t.string :item2_label
      t.text :item2_content
      t.string :item2_position
      t.string :item2_image_alt
      t.text :item2_movie_url

      t.string :item3_label
      t.text :item3_content
      t.string :item3_position
      t.string :item3_image_alt
      t.text :item3_movie_url

      t.string :item4_label
      t.text :item4_content
      t.string :item4_position
      t.string :item4_image_alt
      t.text :item4_movie_url

      t.string :item5_label
      t.text :item5_content
      t.string :item5_position
      t.string :item5_image_alt
      t.text :item5_movie_url

      t.string :item6_label
      t.text :item6_content
      t.string :item6_position
      t.string :item6_image_alt
      t.text :item6_movie_url

      t.string :item7_label
      t.text :item7_content
      t.string :item7_position
      t.string :item7_image_alt
      t.text :item7_movie_url

      t.string :item8_label
      t.text :item8_content
      t.string :item8_position
      t.string :item8_image_alt
      t.text :item8_movie_url

      t.integer :disclose_flg

      t.timestamps
    end
  end
end
