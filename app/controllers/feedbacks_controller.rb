class FeedbacksController < ApplicationController
  protect_from_forgery except: :create

  def index
    @feedbacks = Feedback.includes(:user).all
  end

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.user_id = UserInfo.current_user_id
    if feedback.save
      render json: { message: 'Feedback enviado exitosamente' }, status: :created
    else
      render json: { errors: feedback.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:user_id, :ticket_id, :problem_solved, :advisor_rating, :comments)
  end
end
