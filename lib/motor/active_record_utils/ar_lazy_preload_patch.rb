# frozen_string_literal: true

if Rails::VERSION::MAJOR == 7
  module ArLazyPreload
    module Relation
      def preload_associations(records)
        preload = preload_values
        preload += includes_values unless eager_loading?
        scope = strict_loading_value ? ActiveRecord::Relation::StrictLoadingScope : nil
        preload.each do |associations|
          preloader_associations = ActiveRecord::Associations::Preloader.new(records: records,
                                                                             associations: associations,
                                                                             scope: scope).call

          preloader_associations.each do |preloader_association|
            handle_preloaded_records(preloader_association.preloaded_records)
          end
        end
      end
    end

    module Contexts
      class BaseContext
        def preload_records(association_name, records)
          TemporaryPreloadConfig.within_context do
            ActiveRecord::Associations::Preloader.new(records: records,
                                                      associations: association_name).call
          end
        end
      end
    end
  end
end
