module Admin::MembersHelper
  def filter_options(selected = nil)
    options = []
    User::FILTER_OPTIONS.each do |key|
      options << [I18n.t("admin.sort_field.#{key}"), key]
    end
    options_for_select(options, selected)
  end
end
