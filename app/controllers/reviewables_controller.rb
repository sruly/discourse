class ReviewablesController < ApplicationController
  requires_login

  def index
    reviewables = Reviewable.list_for(current_user, status: :pending)

    # This is a bit awkward, but ActiveModel serializers doesn't seem to serialize STI
    hash = {}
    json = {
      reviewables: reviewables.map do |r|
        result = r.serializer.new(r, root: nil, hash: hash, scope: guardian).as_json
        hash[:reviewable_actions].uniq!
        result
      end,
      meta: {
        types: {
          created_by: 'user'
        }
      }
    }
    json.merge!(hash)

    render_json_dump(json, rest_serializer: true)
  end

  def update
    reviewable = Reviewable.viewable_by(current_user).where(id: params[:reviewable_id]).first
    raise Discourse::NotFound.new if reviewable.blank?

    editable = reviewable.editable_for(guardian)
    raise Discourse::InvalidAccess.new unless editable.present?

    # Validate parameters are all editable
    edit_params = params[:reviewable] || {}
    edit_params.each do |name, value|
      if value.is_a?(ActionController::Parameters)
        value.each do |pay_name, pay_value|
          raise Discourse::InvalidAccess.new unless editable.has?("#{name}.#{pay_name}")
        end
      else
        raise Discourse::InvalidAccess.new unless editable.has?(name)
      end
    end

    if reviewable.update_fields(edit_params, current_user)
      render json: edit_params
    else
      render_json_error(reviewable.errors)
    end
  end

  def perform
    reviewable = Reviewable.viewable_by(current_user).where(id: params[:reviewable_id]).first
    raise Discourse::NotFound.new if reviewable.blank?

    begin
      result = reviewable.perform(current_user, params[:action_id].to_sym)
    rescue Reviewable::InvalidAction => e
      # Consider InvalidAction an InvalidAccess
      raise Discourse::InvalidAccess.new(e.message)
    end

    if result.success?
      render_serialized(result, ReviewablePerformResultSerializer)
    else
      render_json_error(result.errors)
    end
  end
end
