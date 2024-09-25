class CreatePartners < ActiveRecord::Migration[6.1]
  def change
    create_table :partners do |t|
      t.string :name
      t.text :category
      t.text :map_url
      t.string :url
      t.text :privacy_policy
      t.text :mail

      t.text :label
      t.string :main_image_position
      t.text :catch_copy
      t.string :catch_copy_color
      t.string :catch_copy_position
      t.string :main_color

      t.text :contact_mail
      t.text :contact_tel
      t.text :contact_line
      t.text :contact_x
      t.text :contact_fb
      t.text :contact_linkedin
      t.text :contact_insta

      t.string :info1_item
      t.string :info2_item
      t.string :info3_item
      t.string :info4_item
      t.string :info5_item
      t.string :info6_item
      t.string :info7_item
      t.string :info8_item
      t.string :info9_item
      t.string :info10_item
      t.text :info1_content
      t.text :info2_content
      t.text :info3_content
      t.text :info4_content
      t.text :info5_content
      t.text :info6_content
      t.text :info7_content
      t.text :info8_content
      t.text :info9_content
      t.text :info10_content

      t.integer :disclose_flg

      t.timestamps
    end
  end
end
