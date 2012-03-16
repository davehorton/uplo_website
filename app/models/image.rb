class Image < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig
  include ::SharedMethods::Converter

  # ASSOCIATIONS
  belongs_to :gallery
  has_many :image_tags, :dependent => :destroy
  has_many :tags, :through => :image_tags
  has_many :image_likes, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :line_items, :dependent => :destroy
  has_many :orders, :through => :line_items

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
        SharedMethods::Converter::SearchStringConverter.process_special_chars(params[:query]),
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
      [:image_url, :image_thumb_url, :username, :creation_timestamp, :user_fullname, :public_link]
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

  # public link on social network
  def public_link
    url_for :controller => 'images', :action => 'browse', :id => self.id, :only_path => false, :host => DOMAIN
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

  def liked_by_user(user_id)
    result = {:success => false}
    Image.transaction do
      self.likes += 1
      if User.exists? user_id
        img_like = ImageLike.new({:image_id => self.id, :user_id => user_id})
        self.image_likes << img_like
      else
        result[:msg] = "User does not exist anymore"
      end
      self.save
      result[:likes] = self.likes
      result[:success] = true
    end
    return result
  end

  def disliked_by_user(user_id)
    result = {:success => false}
    Image.transaction do
      self.likes -= 1
      if User.exists? user_id
        img_like = ImageLike.find_by_image_id self.id, :conditions => {:user_id => user_id}
        img_like.destroy
      else
        result[:msg] = "User does not exist anymore"
      end
      self.save
      result[:likes] = self.likes
      result[:success] = true
    end
    return result
  end

  def is_liked?(user_id)
    ImageLike.exists?({:image_id => self.id, :user_id => user_id})
  end

  def total_sales
    orders = self.orders.where({:transaction_status => Order::TRANSACTION_STATUS[:complete]}).collect { |o| o.id }
    saled_items = (orders.length==0) ? [] : self.line_items.where("order_id in (#{orders.join(',')})")

    total = 0
    saled_items.each { |item| total += (item.price + item.tax) }
    return total
  end

  def saled_quantity
    orders = self.orders.where({:transaction_status => Order::TRANSACTION_STATUS[:complete]}).collect { |o| o.id }
    saled_items = (orders.length==0) ? [] : self.line_items.where("order_id in (#{orders.join(',')})")

    return saled_items.length
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

  #indexing with thinking sphinx
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
