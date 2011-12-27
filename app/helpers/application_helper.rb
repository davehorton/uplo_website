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
end
