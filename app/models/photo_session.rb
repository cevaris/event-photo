# create_table "photo_sessions", force: true do |t|
#   t.string   "name"
#   t.integer  "photo_user_id"
#   t.integer  "event_id"
#   t.datetime "created_at"
#   t.datetime "updated_at"
#   t.boolean  "claimed",                 default: false
#   t.string   "slug"
#   t.integer  "opened_at",     limit: 8
# end

# add_index "photo_sessions", ["slug"], name: "index_photo_sessions_on_slug", using: :btree

class PhotoSession < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper

  acts_as_taggable_on :emails
  acts_as_taggable_on :phones
  acts_as_taggable_on :attendees

  has_many :photos
  belongs_to :event
  belongs_to :photographer, class_name: 'User', foreign_key: 'photo_user_id'
  accepts_nested_attributes_for :photos, :allow_destroy => true

  validate :phone_list_format

  def phone_list_format
    Rails.logger.info "Phones #{self.phone_list.inspect}"

    if self.phone_list.empty? or self.phone_list == ['']
      errors.add(:phone_list, "is missing.")
    elsif self.phone_list
      phone_list.each do |phone_number|
        errors.add(:phone_list, "has invalid phone format.") unless phone_number =~ User::PHONE_FORMAT
      end
    end
  end


  def url
    Rails.application.routes.url_helpers.photo_session_short_url(self, host: ENV['SHORT_URL'])
  end
  def short_url
    Rails.application.routes.url_helpers.photo_session_short_url(self, host: ENV['SHORT_URL'])[7..-1]
  end

  def is_opened?
    self.opened_at ? true : false
  end

  def time_to_open
    if self.opened_at
      difference = self.opened_at.to_i - self.created_at.to_i
      seconds    =  difference % 60
      difference = (difference - seconds) / 60
      minutes    =  difference % 60
      difference = (difference - minutes) / 60
      hours      =  difference % 24
      difference = (difference - hours)   / 24
      days       =  difference % 7
      weeks      = (difference - days)    /  7
      
      result = []
      if weeks != 0
        result << "#{weeks} weeks"
      end
      if days != 0
        result << "#{days} days"
      end
      if hours != 0
        result << "#{hours} hours"
      end
      if minutes != 0
        result << "#{minutes} mins"
      end
      if seconds != 0
        result << "#{seconds} secs"
      end
      result.join(", ")
    end
  end


  before_save :default_values
  def default_values
    # self.slug ||= SecureRandom.hex[0..10]
    self.slug ||= loop do
      token = SecureRandom.hex[0..3]
      break token unless PhotoSession.exists?(slug: token)
    end
  end

  def to_param
    self.slug
  end 

end
