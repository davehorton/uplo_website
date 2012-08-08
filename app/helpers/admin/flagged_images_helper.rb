module Admin::FlaggedImagesHelper
  def flag_image_types_collection(selected_type = nil)
    collection = []
    selected_type = selected_type.to_i
    
    ImageFlag::FLAG_TYPE.sort_by{|key, value| value}.each do |item|
      if selected_type == item[1]
        # Set the current selected flag type
        @flag_type_key = item[0]
      end
      collection << [I18n.t("admin.flagged_images_type.#{item[0]}"), item[1]]
    end
    
    @flag_type_key ||= "terms_of_use_violation" # To ensure we always have a selected flag type.
    
    return collection
  end
end
