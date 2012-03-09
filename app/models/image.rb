class Image < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig

  # ASSOCIATIONS
  belongs_to :gallery
  has_many :image_tags, :dependent => :destroy
  has_many :tags, :through => :image_tags
  has_many :image_likes, :dependent => :destroy
  has_many :comments, :dependent => :destroy

  # Paperclip
  has_attached_file :data,
   :styles => {:small_preview => "100x100", :thumb => "180x180>", :medium =>  "750x750>", :large => '1000x1000>'},
   :storage => :s3,
   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
   :path => "image/:id/:style.:extension"

  #validates_attachment_presence :data
  validates_attachment_content_type :data, :content_type => [ 'image/jpeg','image/jpg','image/png',"image/gif"],
                                      :message => 'filetype must be one of [.jpeg, .jpg, .png, .gif]'

  # CALLBACK
  after_post_process :save_image_dimensions
  after_initialize :init_random_price

  # CLASS METHODS
  class << self
    def do_search(params = {})
      params[:filtered_params][:sort_field] = 'name' unless params[:filtered_params].has_key?("sort_field")
      paging_info = parse_paging_options(params[:filtered_params], {:sort_mode => :extended})

      self.search(
        params[:query],
        :star => true,
        :page => paging_info.page_id,
        :per_page => paging_info.page_size )
    end

    def load_images(params = {})
      paging_info = parse_paging_options(params)
      paginate(
        :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
    end

    def load_popular_images(params)
      paging_info = parse_paging_options(params, {:sort_criteria => "images.likes DESC"})
      # TODO: calculate the popularity of the images: base on how many times an image is "liked".
      self.includes(:gallery).joins([:gallery]).
            where("galleries.permission = ?", Gallery::PUBLIC_PERMISSION).
            paginate(
              :page => paging_info.page_id,
              :per_page => paging_info.page_size,
              :order => paging_info.sort_string)
    end

    def exposed_methods
      [:image_url, :image_thumb_url, :username, :creation_timestamp, :user_fullname]
    end

    def exposed_attributes
      [:id, :name, :description, :data_file_name, :gallery_id, :price, :likes]
    end

    def exposed_associations
      []
    end

    protected

    def parse_paging_options(options, default_opts = {})
      if default_opts.blank?
        default_opts = {
          :sort_criteria => "images.updated_at DESC"
        }
      end
      paging_options(options, default_opts)
    end
  end

  # INSTANCE METHODS
  def author
    if self.gallery && self.gallery.user
      self.gallery.user
    end
  end

  def username
    user = author
    if user
      return user.username
    end
  end

  def user_fullname
    user = author
    if user
      return user.fullname
    end
  end

  def image_url
    data.url
  end

  def image_thumb_url
    data.url(:thumb)
  end

  def creation_timestamp
    ::Util.distance_of_time_in_words_to_now(self.created_at)
  end

  # Shortcut to get image's URL
  def url(options = nil)
    self.data.url(options)
  end

  def is_likable(user_id)
    if !User.exists?(user_id)
      result = false #raise exception
    elsif ImageLikes.exists?({:image_id => self.id, :user_id => user_id})
      result = true
    else
      result = false
    end

    return result
  end

  protected

  # Detect the image dimensions.
  def save_image_dimensions
    file = self.data.queued_for_write[:original]
    if file.blank?
      file = data.url(:original)
    end

    geo = Paperclip::Geometry.from_file(file)
    self.width = geo.width
    self.height = geo.height
  end

  # TODO: this method is for test only. Please REMOVE this in production mode.
  def init_random_price
    if self.price.blank?
      self.price = rand(50)
    end
  end

  # indexing with thinking sphinx
  define_index do
    indexes name
    indexes description

    has gallery_id

    set_property :field_weights => {
      :name => 4,
      :description => 1,
    }

    if Rails.env.production?
      set_property :delta => FlyingSphinx::DelayedDelta
    else
      set_property :delta => true
    end
  end
end
