# Copyright (C) 2012-2024 Zammad Foundation, https://zammad-foundation.org/

class TriggerWebhookJob::CustomPayload::Track::Group < TriggerWebhookJob::CustomPayload::Track
  def self.klass
    'Group'
  end
end
