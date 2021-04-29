# frozen_string_literal: true

module Motor
  class ActiveStorageAttachmentsController < ApiBaseController
    wrap_parameters :data, except: %i[include fields]

    load_and_authorize_resource :attachment, class: 'ActiveStorage::Attachment', parent: false

    def create
      if @attachment.record.respond_to?("#{@attachment.name}_attachment=") || @attachment.record.respond_to?("#{@attachment.name}_attachments=")
        @attachment.record.public_send(@attachment.name).attach(
          io: StringIO.new(params.dig(:data, :file, :io).to_s.encode('ISO-8859-1')),
          filename: params.dig(:data, :file, :filename)
        )

        head :ok
      else
        head :unprocessable_entity
      end
    end

    private

    def attachment_params
      params.require(:data).except(:file).permit!
    end
  end
end
