# Copyright (C) 2012-2023 Zammad Foundation, https://zammad-foundation.org/

class Controllers::FeedbacksControllerPolicy < Controllers::ApplicationControllerPolicy
  permit! %i[index], to: 'admin.object'
  permit! %i[create], to: ['ticket.agent', 'ticket.customer']
end
