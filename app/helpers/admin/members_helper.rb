module Admin::MembersHelper
  def member_filter_options(selected = nil)
    options = []
    User::FILTER_OPTIONS.each do |key|
      options << [I18n.t("admin.sort_field.#{key}"), key]
    end
    options_for_select(options, selected)
  end
  
  def current_sort_direction(value, current_value)
    (value.to_s.downcase == current_value.to_s.downcase ? "current" : "")
  end
end
