module ReviewsHelper
  def organize_ratings(review)
    return [
      { name: :usability, value: review.usabilityRating },
      { name: :coverage, value: review.coverageRating },
      { name: :quality, value: review.qualityRating },
      { name: :formality, value: review.formalityRating },
      { name: :correctness, value: review.correctnessRating },
      { name: :documentation, value: review.documentationRating }
    ]
  end
end
