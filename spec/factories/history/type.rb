# Copyright (C) 2012-2023 Zammad Foundation, https://zammad-foundation.org/

FactoryBot.define do
  factory :'history/type', aliases: %i[history_type] do
    name do
      # The following line ensures that the name generated by Faker
      # does not conflict with any existing names in the DB.
      Faker::Verb.unique.exclude(:past_participle, [], History::Type.pluck(:name))

      Faker::Verb.unique.past_participle
    end
  end
end