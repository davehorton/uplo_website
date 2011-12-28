module ApplicationHelper
  def jquery_include_tag(all = true)
    if all
      javascript_include_tag("lib/jquery.min.js", "lib/jquery.livequery.js", "lib/jquery.ui.core.js")
    else
      javascript_include_tag("lib/jquery.min.js")
    end
  end
  
  def jquery_ui_css_tag
    stylesheet_link_tag("jquery-ui.custom.css")
  end
  
  def js_menu_include_tag
    javascript_include_tag("lib/superfish.min.js", "lib/supersubs.min.js")
  end
  
  def set_current_tab(item)
    (current_tab.to_s == item.to_s) ? "current" : ""
  end

  # assign the current tab based on the given name, default to dashboard
  def current_tab
    @current_tab ||= "popular"
  end
end
