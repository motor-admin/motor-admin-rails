# frozen_string_literal: true

module Motor
  class ActiveStorageAttachmentsController < ApiBaseController
    include Motor::WrapIoParams

    before_action :wrap_io_params, only: :create

    wrap_parameters :data, except: %i[include fields]

    load_and_authorize_resource :attachment, class: 'ActiveStorage::Attachment', parent: false

    def create
      blob = if file_params[:key]
               ActiveStorage::Blob.create!(file_params)
             else
               ActiveStorage::Blob.create_and_upload!(file_params)
             end

      @attachment.assign_attributes(blob: blob, record: record)
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
      attrs = params.require(:data).require(:file).permit(:io, :filename, :key,
                                                          :checksum, :byte_size,
                                                          :content_type).to_h.symbolize_keys

      return attrs if params.dig(:data, :file, :base64).blank?

      attrs[:io] = StringIO.new(Base64.urlsafe_decode64(params[:data][:file][:base64]))

      attrs
    end

    def attachment_params
      if params[:data].present?
        params.require(:data).except(:file).permit(:name, :record_type, :record_id)
      else
        {}
      end
    end
  end
end
