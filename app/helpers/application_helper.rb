module ApplicationHelper
  def jquery_include_tag(all = false)
    if all
      javascript_include_tag("lib/jquery.js", "lib/jquery.livequery.min.js", "lib/jquery.ui.core.min.js")
    else
      javascript_include_tag("lib/jquery.js")
    end
  end
end
