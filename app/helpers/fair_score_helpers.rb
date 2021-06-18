module FairScoreHelpers

  def fair_scores_data
    return nil if @fair_scores.nil?
    return @fair_scores_data  if @fair_scores_data

    keys_filter  = ["score" ,"normalizedScore" , "maxCredits" , "portalMaxCredits"]

    @fair_scores_data = {}
    @fair_scores_data[:principles] = {labels:[] , scores:[] , normalizedScores: [] , maxCredits: [] , portalMaxCredits: []}
    @fair_scores_data[:criteria] = { labels:[] , scores:[] , normalizedScores: [] , portalMaxCredits: [], questions: [] ,maxCredits: []}
    @fair_scores_data[:score] = @fair_scores["score"]
    @fair_scores_data[:normalizedScore] = @fair_scores["normalizedScore"]

    @fair_scores.to_h.keys.reject { |k| keys_filter.include? k }.each do |principle|
      @fair_scores_data[:principles][:labels] << principle
      @fair_scores_data[:principles][:scores] << @fair_scores[principle]["score"]
      @fair_scores_data[:principles][:normalizedScores] << @fair_scores[principle]["normalizedScore"]
      @fair_scores_data[:principles][:maxCredits] << @fair_scores[principle]["maxCredits"]
      @fair_scores_data[:principles][:portalMaxCredits] << @fair_scores[principle]["portalMaxCredits"]

      @fair_scores[principle].to_h.keys.reject { |k| keys_filter.include? k }.each do  |criterion|
        @fair_scores_data[:criteria][:labels] << criterion
        @fair_scores_data[:criteria][:scores] << @fair_scores[principle][criterion]["score"]
        @fair_scores_data[:criteria][:normalizedScores] << @fair_scores[principle][criterion]["normalizedScore"]
        @fair_scores_data[:criteria][:questions] << @fair_scores[principle][criterion]["results"]
        @fair_scores_data[:criteria][:maxCredits] << @fair_scores[principle][criterion]["maxCredits"]
        @fair_scores_data[:criteria][:portalMaxCredits] << @fair_scores[principle][criterion]["portalMaxCredits"]
      end
    end
    @fair_scores_data
  end


  def get_not_obtained_score(score, maxPortalCredits , maxCredits)
    ((maxPortalCredits / maxCredits) * 100 ).round - score
  end
end

