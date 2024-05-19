class Feedback < ApplicationModel
	belongs_to :user
	validates :problem_solved, inclusion: { in: [true, false] }
	validates :advisor_rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
end