class Admin::NewsEntriesController < ApplicationController
  PER_PAGE = 20

  layout :determine_layout
  before_action :require_news_cms
  before_action :authorize_admin
  before_action :set_news_entry, only: %i[edit update destroy]

  def index
    @news_entries = NewsEntry.order(created_at: :desc).paginate(page: params[:page], per_page: PER_PAGE)
  end

  def new
    @news_entry = NewsEntry.new(status: 'draft')
  end

  def create
    @news_entry = NewsEntry.new(news_entry_params)
    set_author(@news_entry)
    if @news_entry.save
      redirect_to admin_news_entries_path, notice: 'News entry created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @news_entry.update(news_entry_params)
      redirect_to admin_news_entries_path, notice: 'News entry updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @news_entry.destroy
    redirect_to admin_news_entries_path, notice: 'News entry deleted.'
  end

  private

  def require_news_cms
    head :not_found unless helpers.news_cms_enabled?
  end

  def set_news_entry
    @news_entry = NewsEntry.find(params[:id])
  end

  def set_author(entry)
    user = session[:user]
    entry.author_id = user.id.to_s if user.respond_to?(:id)
    entry.author_name = user.username.to_s if user.respond_to?(:username)
  end

  def news_entry_params
    params.require(:news_entry).permit(
      :title, :slug, :excerpt, :body_html, :status, :published_at, :expires_at, :pinned
    )
  end
end
