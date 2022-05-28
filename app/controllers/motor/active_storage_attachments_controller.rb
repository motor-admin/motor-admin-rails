# frozen_string_literal: true

module Motor
  class ActiveStorageAttachmentsController < ApiBaseController
    include Motor::WrapIoParams

    wrap_parameters :data, except: %i[include fields]

    load_and_authorize_resource :attachment, class: 'ActiveStorage::Attachment', parent: false

    def create
      @attachment.assign_attributes(blob: ActiveStorage::Blob.create_and_upload!(file_params), record: record)
      @attachment.assign_attributes(record_type: '', record_id: 0) unless record

      if @attachment.save(validate: false)
        render json: { data: Motor::ApiQuery::BuildJson.call(@attachment, params, current_ability) }
      else
        render json: { errors: @attachment.errors }, status: :unprocessable_entity
      end
    end

    private

    def record
      @record ||=
        if @attachment.record
          record_pk = @attachment.record.class.primary_key

          Motor::Resources::FetchConfiguredModel.call(
            @attachment.record.class,
            cache_key: Motor::Resource.maximum(:updated_at)
          ).find_by(record_pk => @attachment.record[record_pk])
        else
          current_user
        end
    end

    def file_params
      params.require(:data).require(:file).permit(:io, :filename).to_h.symbolize_keys
    end

    def attachment_params
      if params[:data].present?
        params.require(:data).except(:file).permit!
      else
        {}
      end
    end
  end
end
