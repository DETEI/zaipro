# Copyright (C) 2012-2024 Zammad Foundation, https://zammad-foundation.org/

class Ticket::StateType < ApplicationModel
  include HasDefaultModelUserRelations

  include CanBeImported
  include ChecksHtmlSanitized

  has_many :states, class_name: 'Ticket::State', inverse_of: :state_type

  validates :name, presence: true

  validates :note, length: { maximum: 250 }
  sanitized_html :note
end
