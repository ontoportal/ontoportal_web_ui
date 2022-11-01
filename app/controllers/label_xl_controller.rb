class LabelXlController < ApplicationController
  include LabelXlHelper

  def show
    @label_xl = get_request_label_xl
  end

  def show_label
    label_xl = get_request_label_xl
    label_xl_label = label_xl ? label_xl['literalForm'] : nil
    label_xl_label = params[:id] if label_xl_label.nil? || label_xl_label.empty?

    render plain: label_xl_label + "<i class='fas fa-external-link-alt mx-1'></i>"
  end

  private

  def get_request_label_xl
    params[:id] = params[:id] ? params[:id] : params[:label_xl_id]
    params[:ontology_id] = params[:ontology_id] ? params[:ontology_id] : params[:ontology]
    if params[:id].nil? || params[:id].empty?
      render text: 'Error: You must provide a valid label_xl id'
      return
    end
    @ontology_acronym = params[:ontology_id]
    get_label_xl(params[:ontology_id], params[:cls_id], params[:id])
  end

end
