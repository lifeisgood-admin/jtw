class AddCatchPhrasesToPartners < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :catch_phrase, :string
  end
end
