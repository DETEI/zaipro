class CreateFeedback < ActiveRecord::Migration[6.1]
  def change
    create_table :feedbacks do |t|
      t.references :user
      t.references :ticket
      t.boolean :problem_solved
      t.integer :advisor_rating
      t.text :comments
      t.timestamps
    end
  end
end
