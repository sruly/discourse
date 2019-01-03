class ReviewablePerformResultSerializer < ApplicationSerializer

  attributes(
    :success,
    :transition_to,
    :transition_to_id,
    :created_post_id,
    :created_post_topic_id,
    :remove_reviewable_ids
  )

  def success
    object.success?
  end

  def transition_to_id
    Reviewable.statuses[transition_to]
  end

  def created_post_id
    object.created_post.id
  end

  def include_created_post_id?
    object.created_post.present?
  end

  def created_post_topic_id
    object.created_post_topic.id
  end

  def include_created_post_topic_id?
    object.created_post_topic.present?
  end
end
