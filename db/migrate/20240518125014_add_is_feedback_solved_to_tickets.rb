class AddIsFeedbackSolvedToTickets < ActiveRecord::Migration[6.1]
  def change
    add_column :tickets, :feedback_solved, :boolean, default: false, null: false
  end
end
