# Copyright (C) 2012-2024 Zammad Foundation, https://zammad-foundation.org/

module Gql::Types::Concerns::HasModelRelations
  extend ActiveSupport::Concern

  class_methods do

    # Using AssociationLoader with has_many and has_and_belongs_to_many didn't work out,
    #   because the ConnectionTypes generate their own, non-preloadable queries.
    # See also https://github.com/Shopify/graphql-batch/issues/114.

    def belongs_to(association, *args, **kwargs, &)
      kwargs[:resolver_class] = Gql::Resolvers::BelongsToResolver

      field(association, *args, **kwargs, is_dependent_field: true, &)
    end

    def has_one(association, *args, **kwargs, &)
      kwargs[:resolver_class] = Gql::Resolvers::HasOneResolver

      field(association, *args, **kwargs, is_dependent_field: true, &)
    end

    def lookup_field(name, *args, **kwargs, &)
      kwargs[:resolver_class] = Gql::Resolvers::LookupResolver

      field(name, *args, **kwargs, &)
    end
  end
end
