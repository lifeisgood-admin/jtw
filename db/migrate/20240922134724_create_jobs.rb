class CreateJobs < ActiveRecord::Migration[6.1]
  def change
    create_table :jobs do |t|
      t.integer :partner_id
      t.text :movie_url
      t.text :title
      t.text :main_content
      t.text :free_comment
      t.text :background
      t.text :job_fun
      t.text :qualification
      t.text :preferable_exp
      t.text :hire_num
      t.integer :min_age
      t.integer :max_age
      t.text :age_reason
      t.string :emp_status
      t.text :trial_period
      t.text :work_time
      t.text :work_location
      t.text :pref
      t.text :city
      t.text :street
      t.text :station
      t.text :income
      t.string :income_style
      t.integer :min_income
      t.integer :max_income
      t.text :treatment
      t.text :holiday
      t.text :work_place_note
      t.text :selection_process
      t.string :free_title1
      t.text :free_content1
      t.string :free_title2
      t.text :free_content2
      t.string :free_title3
      t.text :free_content3
      
      t.string :label

      t.text :search_job
      t.text :search_feature
      t.text :search_location
      
      t.integer :disclose_flg

      t.timestamps
    end
  end
end
