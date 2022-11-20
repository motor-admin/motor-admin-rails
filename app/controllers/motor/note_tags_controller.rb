# frozen_string_literal: true

module Motor
  class NoteTagsController < ApiBaseController
    wrap_parameters :data, except: %i[include fields]

    load_and_authorize_resource :note_tag

    def index
      render json: { data: @note_tags.to_a }
    end
  end
end
