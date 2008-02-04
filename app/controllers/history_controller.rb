class HistoryController < ApplicationController
  
  def remove
      puts "Tab should be removed"
      puts params[:ontology]
      remove_tab(undo_param(params[:ontology]))
      render :text =>"success"
  end
  
  def update
    update_tab(undo_param(params[:ontology]),params[:concept])
    render :text =>"success"
  end
  
  
end
