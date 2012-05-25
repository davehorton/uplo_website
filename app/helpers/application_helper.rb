module ApplicationHelper
  def state_options
    options_for_select({
      'Alaska' => 'AK', 'Alabama' => 'AL', 'Arkansas' => 'AR', 'American Samoa' => 'AS', 'Arizona' => 'AZ',
      'California' => 'CA', 'Colorado' => 'CO', 'Connecticut' => 'CT', 'D.C.' => 'DC', 'Delaware' => 'DE',
      'Florida' => 'FL', 'Micronesia' => 'FM',
      'Georgia' => 'GA', 'Guam' => 'GU',
      'Hawaii' => 'HI',
      'Iowa' => 'IA', 'Idaho' => 'ID', 'Illinois' => 'IL', 'Indiana' => 'IN',
      'Kansas' => 'KS', 'Kentucky' => 'KY',
      'Louisiana' => 'LA',
      'Massachusetts' => 'MA', 'Maryland' => 'MD', 'Maine' => 'ME', 'Marshall Islands' => 'MH', 'Michigan' => 'MI',
      'Minnesota' => 'MN', 'Missouri' => 'MO', 'Marianas' => 'MP', 'Mississippi' => 'MS', 'Montana' => 'MT',
      'North Carolina' => 'NC', 'North Dakota' => 'ND', 'Nebraska' => 'NE', 'New Hampshire' => 'NH',
      'New Jersey' => 'NJ', 'New Mexico' => 'NM', 'Nevada' => 'NV', 'New York' => 'NY',
      'Ohio' => 'OH', 'Oklahoma' => 'OK', 'Oregon' => 'OR',
      'Pennsylvania' => 'PA', 'Puerto Rico' => 'PR', 'Palau' => 'PW',
      'Rhode Island' => 'RI',
      'South Carolina' => 'SC', 'South Dakota' => 'SD',
      'Tennessee' => 'TN', 'Texas' => 'TX',
      'Utah' => 'UT',
      'Virginia' => 'VA', 'Virgin Islands' => 'VI', 'Vermont' => 'VT',
      'Washington' => 'WA', 'Wisconsin' => 'WI', 'West Virginia' => 'WV', 'Wyoming' => 'WY',
      'Military Americas' => 'AA', 'Military Europe/ME/Canada' => 'AE', 'Military Pacific' =>  'AP'
    })
  end

  def popular_sort_options
    options_for_select([["Most Views", "#"]])
  end

  def private_links_options
    options_for_select([["My UPLO", "#"], ['My Profile', '/my_profile'], ["My Account", "/my_account"], ["My Galleries", "/galleries"], ["My Sales", "/sales"]])
  end

  def redirect_back_url
    url = session[:back_url].nil? ? root_url : session[:back_url]
    return url
  end

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

  def render_pagination(data_source, params = {})
    return nil if data_source.blank?
    will_paginate(data_source, {
      :previous_label => "<",
      :next_label => ">",
      :param_name => "page_id",
      :params => params
    })
  end

  # This is a helper to use with the JAIL (jQuery Asynchronous Image Loader plugin)
  def async_image_tag(source, options = {})
    options ||= {}
    image_html = ""
    if @no_async_image_tag
      image_html = image_tag_ex(source, options)
    else
      image_html = image_tag_ex("blank.png", options.merge({"data-href" => path_to_image(source)}))
      image_html << content_tag("noscript") do # Tag to show image when the JS is disabled.
        image_tag_ex(source, options)
      end
    end
    render :inline => image_html
  end

  # This is an extension method for image_path to help you can use <img> tag in HTML email.
  def image_tag_ex(source, options = {})
    path = source

    if @use_absolute_asset_path
      path = path_to_image(source)
      if path && path.index("http") != 0
        # If it runs to here, it means that the path is not absolute.
        host = ActionMailer::Base.default_url_options[:host]
        if host && host.index("http") != 0
          scheme = (SslRequirement.ssl_required_all? ? "https" : "http")
          host = "#{scheme}://#{host}"
        end
        path = File.join(host, path)
      end
    end

    image_tag(path, options)
  end

  def gender_options
    [ [I18n.t("common.male"), 0],
      [I18n.t("common.female"), 1]
    ]
  end
end
