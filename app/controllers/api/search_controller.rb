class Api::SearchController < Api::BaseController
  before_filter :require_login!
  SEARCH_TYPE = {
    "users" => User,
    "galleries" => Gallery,
    "images" => Image
  }
  
  # GET /api/search
  # params: 
  #   query: search key
  #   search_type: take value in [nil, "users", "galleries", "images"]
  #   page_id
  #   page_size
  #   sort_field
  #   sort_direction
  def search
    result = {}
    
    search_params = {:query => params[:query], :filtered_params => @filtered_params}
    if params[:search_type].nil?
      result = search_global search_params        
      result[:success] = true
    elsif SEARCH_TYPE.has_key?(params[:search_type])
      list = SEARCH_TYPE[params[:search_type]].do_search search_params
      result[params[:search_type]] = {}
      result[params[:search_type]][:total] = list.total_entries
      result[params[:search_type]][:data] = list
      result[:success] = true
    else
      result[:success] = false
      result[:msg] = "This kind of search does not exist."
    end
    
    render :json => result
  end
  
  protected
  def galleries_to_json(galleries)
    json_array = []
    
    galleries.each do |gallery|
      data = {}
      data[:gallery] = gallery.serializable_hash({ 
        :except => gallery.except_attributes,
        :methods => gallery.exposed_methods, 
      })
      
      if data[:gallery][:cover_image]
        data[:gallery][:cover_image] = data[:gallery][:cover_image].serializable_hash(Image.default_serializable_options)
      end
      
      json_array << data
    end
    
    return json_array
  end
  
  def search_global(params)
    rs = {}
    users = User.do_search params
    images = Image.do_search params
    galleries = Gallery.do_search params
  
    users_info = {}
    users_info[:total] = users.total_entries
    users_info[:data] = users
    rs[:users] = users_info
    
    gals_info = {}
    gals_info[:total] = galleries.total_entries
    gals_info[:data] = galleries_to_json(galleries)
    rs[:galleries] = gals_info
    
    imgs_info = {}
    imgs_info[:total] = galleries.total_entries
    imgs_info[:data] = images
    rs[:images] = imgs_info
    
    return rs
  end
end
