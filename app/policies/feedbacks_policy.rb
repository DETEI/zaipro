# Copyright (C) 2012-2023 Zammad Foundation, https://zammad-foundation.org/

class Feedback::FeedbacksPolicy < ApplicationPolicy

  def create?
    access?(__method__)
  end

  def show?
    access?(__method__)
  end

  private

  def access?(_method)
    return if !user.permissions?('ticket.customer')

    user.feedbacks.access(:create).include? record.feedbacks
  end

end
