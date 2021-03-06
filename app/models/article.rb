class Article < ActiveRecord::Base

  has_attached_file :image,
                    :styles => { :thumb => "64x64#", :small => "128x128#", :normal => "256x256#" },
                    :storage => :Dropboxstorage,
                    :path => "/:class/:attachment/:id/:style/:filename",
                    :url => "http://dl.dropbox.com/u/47883552/:class/:attachment/:id/:style/:filename"

  validates_presence_of :title, :body, :published_at

   # handling delete in your model, if needed. Replace all image occurences with your asset name.
  attr_accessor :delete_image
  before_validation { self.image = nil if self.delete_image == '1' }


  default_scope :order => "published_at DESC"
  scope :published, lambda { where("published_at <= ?", Date.today) }
  scope :lastest, lambda { |n| published.limit(n) }

  def self.group_published
    articles = Article.published.group_by { |article| article.published_at.beginning_of_year }

    articles.each do |key, value|
      articles[key] = value.group_by { |article| article.published_at.beginning_of_month }
    end
    articles
  end
end
