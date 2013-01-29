# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  image_id    :integer
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Comment < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig

  # Associations
  belongs_to :user
  belongs_to :image

  validates_presence_of :user_id, :image_id, :messages => 'cannot be blank'
  scope :available, joins(:user).where('users.is_banned <> ? AND users.is_removed <> ?', true, true).readonly(false)

  class << self
    def load_comments(params = {})
      paging_info = parse_paging_options(params)
      paginate(
        :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
    end

    def exposed_methods
      [ :duration, :commenter, :commenter_id, :commenter_avatar ]
    end

    def exposed_attributes
      [ :description ]
    end

    def exposed_associations
      []
    end

    # protected

    def parse_paging_options(options, default_opts = {})
      if default_opts.blank?
        default_opts = {
          :sort_criteria => "comments.created_at DESC"
        }
      end
      paging_options(options, default_opts)
    end
  end

  def duration
    ::Util.distance_of_time_in_words_to_now(self.created_at)
  end

  def commenter_id
    self.user.id
  end

  def commenter
    self.user.username
  end

  def commenter_avatar(size='large')
    self.user.avatar_url(size)
  end
end
