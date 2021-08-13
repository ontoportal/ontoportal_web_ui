module FairScoreHelper


  def get_fairness_json(ontologies_acronyms)
    MultiJson.load(Faraday.get("#{$FAIRNESS_URL}/?portal=#{$HOSTNAME.split('.')[0]}&ontologies=#{ontologies_acronyms}&combined=true").body.force_encoding('ISO-8859-1').encode('UTF-8'))
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
    fair_scores_data[:score] = fair_scores["score"].to_f.round(2)
    fair_scores_data[:normalizedScore] = fair_scores["normalizedScore"].to_f.round(2)
    fair_scores_data[:resourceCount] = count unless  count.nil?

    fair_scores.to_h.reject { |k,v| !(v.is_a? Hash) }.each do |key ,principle|

      fair_scores_data[:principles][:labels] << key
      fair_scores_data[:principles][:scores] << (principle["score"].to_f.round(2))
      fair_scores_data[:principles][:normalizedScores] << (principle["normalizedScore"].to_f.round(2))
      fair_scores_data[:principles][:maxCredits] << principle["maxCredits"]
      fair_scores_data[:principles][:portalMaxCredits] << principle["portalMaxCredits"]

      principle.to_h.reject { |k,v| !(v.is_a? Hash)  }.each do  |key , criterion|
        fair_scores_data[:criteria][:labels] << key
        fair_scores_data[:criteria][:descriptions] << criterion["label"]
        fair_scores_data[:criteria][:scores] << (criterion["score"].to_f.round(2))
        fair_scores_data[:criteria][:normalizedScores] << (criterion["normalizedScore"].to_f.round(2))

        fair_scores_data[:criteria][:questions] << criterion["results"]

        fair_scores_data[:criteria][:maxCredits] << criterion["maxCredits"]
        fair_scores_data[:criteria][:portalMaxCredits] << criterion["portalMaxCredits"]
      end
    end
    fair_scores_data
  end

  def get_not_obtained_score(fair_scores_data, index)
      fair_scores_data[:criteria][:scores][index] - fair_scores_data[:criteria][:portalMaxCredits][index]
  end

  def get_not_obtained_score_normalized(fair_scores_data, index)
    score_rest = get_rest_score(fair_scores_data,index)
    not_obtained_score = get_not_obtained_score(fair_scores_data , index)

    if  not_obtained_score > 0 && score_rest > 0
        not_obtained_score_normalized = ((not_obtained_score /  fair_scores_data[:criteria][:maxCredits][index]) * 100).round()
    elsif score_rest == 0
        not_obtained_score_normalized = 100 - fair_scores_data[:criteria][:normalizedScores][index]
    else
        not_obtained_score_normalized = 0
    end

    not_obtained_score_normalized
  end

  def get_rest_score(fair_scores_data, index)
    fair_scores_data[:criteria][:maxCredits][index] - fair_scores_data[:criteria][:portalMaxCredits][index]
  end

  def get_rest_score_normalized(fair_scores_data, index)
    score_rest = get_rest_score(fair_scores_data ,index)
    not_obtained_score_normalized = get_not_obtained_score_normalized(fair_scores_data , index)

    if score_rest.positive?
      100 - not_obtained_score_normalized - @fair_scores_data[:criteria][:normalizedScores][index]
    else
      0
    end

  end

  def not_implemented?(question)
    properties = question["properties"]
    score = question ["score"]
    (properties.nil? || properties.empty?) && score.zero?
  end

  def default_score?(question)
    properties = question["properties"]
    score = question ["score"]

    (properties.nil? || properties.empty?) && score.positive?
  end
end

