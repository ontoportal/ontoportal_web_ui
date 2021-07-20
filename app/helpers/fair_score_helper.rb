module FairScoreHelper


  def get_fairness_json(ontologies_acronyms)
      MultiJson.load(Faraday.get("#{$FAIRNESS_URL}/?portal=#{$HOSTNAME.split('.')[0]}&ontologies=#{ontologies_acronyms}&combined=true").body)
  end

  def get_fair_score(ontologies_acronyms)
    get_fairness_json(ontologies_acronyms)["ontologies"]
  end

  def get_fair_combined_score(ontologies_acronyms)
    get_fairness_json(ontologies_acronyms)["combinedScores"]
  end

  def create_fair_scores_data(fair_scores , count = nil)
    return nil if fair_scores.nil?

    fair_scores_data = {}
    fair_scores_data[:principles] = {labels:[] , scores:[] , normalizedScores: [] , maxCredits: [] , portalMaxCredits: []}
    fair_scores_data[:criteria] = { labels:[] , scores:[] , normalizedScores: [] , portalMaxCredits: [], questions: [] ,maxCredits: [] , descriptions: []}
    fair_scores_data[:score] = fair_scores["score"]
    fair_scores_data[:normalizedScore] = fair_scores["normalizedScore"]
    fair_scores_data[:resourceCount] = count unless  count.nil?

    fair_scores.to_h.reject { |k,v| !(v.is_a? Hash) }.each do |key ,principle|

      fair_scores_data[:principles][:labels] << key
      fair_scores_data[:principles][:scores] << principle["score"]
      fair_scores_data[:principles][:normalizedScores] << principle["normalizedScore"]
      fair_scores_data[:principles][:maxCredits] << principle["maxCredits"]
      fair_scores_data[:principles][:portalMaxCredits] << principle["portalMaxCredits"]

      principle.to_h.reject { |k,v| !(v.is_a? Hash)  }.each do  |key , criterion|
        fair_scores_data[:criteria][:labels] << key
        fair_scores_data[:criteria][:descriptions] << criterion["label"]
        fair_scores_data[:criteria][:scores] << criterion["score"]
        fair_scores_data[:criteria][:normalizedScores] << criterion["normalizedScore"]
        fair_scores_data[:criteria][:questions] << criterion["results"]
        fair_scores_data[:criteria][:maxCredits] << criterion["maxCredits"]
        fair_scores_data[:criteria][:portalMaxCredits] << criterion["portalMaxCredits"]
      end
    end
    fair_scores_data
  end

  def get_not_obtained_score(score, max_portal_credits , max_credits)
    ((max_portal_credits / max_credits) * 100 ).round - score
  end
end

