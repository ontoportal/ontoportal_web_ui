class NewsController < ApplicationController
  PUBLIC_ENTRY_LIMIT = 20

  layout :determine_layout
  before_action :require_news_cms

  def index
    @news_entries = NewsEntry.published.limit(PUBLIC_ENTRY_LIMIT)
    respond_to do |format|
      format.html
      format.rss { render :index, formats: :rss }
      format.atom { render :index, formats: :atom }
    end
  end

  def show
    @news_entry = NewsEntry.published.find_by!(slug: params[:slug])
  end

  private

  def require_news_cms
    head :not_found unless helpers.news_cms_enabled?
  end
end
