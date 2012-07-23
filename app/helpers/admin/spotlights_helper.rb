module Admin::SpotlightsHelper
  def image_filter_options(selected = nil)
    options = []
    Image::FILTER_OPTIONS.each do |key|
      options << [I18n.t("admin.sort_field.#{key}"), key]
    end
    options_for_select(options, selected)
  end
end
