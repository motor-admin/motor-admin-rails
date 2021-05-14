# frozen_string_literal: true

module Motor
  module Forms
    module Persistance
      NameAlreadyExists = Class.new(StandardError)

      module_function

      def build_from_params(params, current_user = nil)
        form = assign_attributes(Form.new, params)

        form.author = current_user

        form
      end

      def create_from_params!(params, current_user = nil)
        raise NameAlreadyExists if Form.exists?(['lower(name) = ?', params[:name].to_s.downcase])

        form = build_from_params(params, current_user)

        ApplicationRecord.transaction do
          form.save!
        end

        form
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def update_from_params!(form, params)
        tag_ids = form.tags.ids

        form = assign_attributes(form, params)

        raise NameAlreadyExists if name_already_exists?(form)

        ApplicationRecord.transaction do
          form.save!
        end

        form.touch if tag_ids.sort != form.tags.reload.ids.sort

        form
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def assign_attributes(form, params)
        form.assign_attributes(params.slice(:name, :description, :api_path, :http_method, :preferences))

        Motor::Tags.assign_tags(form, params[:tags])
      end

      def name_already_exists?(form)
        if form.new_record?
          Form.exists?(['lower(name) = ?', form.name.to_s.downcase])
        else
          Form.exists?(['lower(name) = ? AND id != ?', form.name.to_s.downcase, form.id])
        end
      end
    end
  end
end
