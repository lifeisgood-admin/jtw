class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.integer :partner_id
      t.boolean :admin_flg
      
      t.string :name
      t.string :mail
      t.string :password_digest

      t.timestamps
    end
  end
end
