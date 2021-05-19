# frozen_string_literal: true

module Motor
  class ActiveStorageAttachmentsController < ApiBaseController
    include Motor::WrapIoParams

    wrap_parameters :data, except: %i[include fields]

    load_and_authorize_resource :attachment, class: 'ActiveStorage::Attachment', parent: false

    def create
      if attachable?(@attachment.record)
        @attachment.record.public_send(@attachment.name).attach(file_params)

        head :ok
      else
        head :unprocessable_entity
      end
    end

    private

    def attachable?(record)
      record.respond_to?("#{@attachment.name}_attachment=") ||
        record.respond_to?("#{@attachment.name}_attachments=")
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
