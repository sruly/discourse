class CreateReviewableScores < ActiveRecord::Migration[5.2]
  def change
    create_table :reviewable_scores do |t|
      t.integer :reviewable_id, null: false
      t.integer :user_id, null: false
      t.integer :reviewable_score_type, null: false
      t.integer :status, null: false
      t.float :score, null: false, default: 0
      t.timestamps
    end

    add_index :reviewable_scores, :reviewable_id
  end
end
