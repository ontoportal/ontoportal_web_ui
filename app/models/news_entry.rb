class NewsEntry < ApplicationRecord
  STATUSES = %w[draft published].freeze

  validates :title, :body_html, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :slug, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }

  before_validation :set_slug
  before_validation :sanitize_body

  scope :published, -> {
    now = Time.current
    where(status: 'published')
      .where('published_at IS NULL OR published_at <= ?', now)
      .where('expires_at IS NULL OR expires_at > ?', now)
      .order(pinned: :desc, published_at: :desc, created_at: :desc)
  }

  def excerpt(length = 240)
    source = self[:excerpt].presence || body_html
    ActionController::Base.helpers.strip_tags(source.to_s).squish.truncate(length)
  end

  private

  def set_slug
    self.slug = title.to_s.parameterize if slug.blank?
    self.slug = slug.to_s.parameterize if slug.present?
  end

  def sanitize_body
    self.body_html = ActionController::Base.helpers.sanitize(body_html.to_s)
  end
end
