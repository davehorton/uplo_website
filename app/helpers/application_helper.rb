module ApplicationHelper
  # this helper generates the body tag for a page or layout, e.g.
  #
  # <body id="[controller_name]-body" class="[specified classes]">
  # ...content...
  # </body>
  #
  # options:
  #  id: ID for body tag, defaults to "body-[controller_name]".
  #  class: class (or classes) for the body tag, will not be added unless specified.
  def body_tag(opts = {}, &block)
    opts[:id] = content_for?(:body_id) ? content_for(:body_id) : "body-"+controller_name.dasherize
    opts[:class] = content_for(:body_class) if content_for?(:body_class)
    content_tag(:body, opts, &block)
  end

  # uses action and controller name if title is not already set (see page_title)
  def page_title_with_default
    if content_for?(:page_title)
      title = content_for(:page_title)
    else
      title = "#{action_name.humanize.titleize} #{controller_name.humanize.singularize}"
    end

    title  + ' | ' + t('common.site_title')
  end

  # sets current page title
  def page_title(name)
    content_for(:page_title, name)
  end

  def yield_content!(content_key)
    view_flow.content.delete(content_key)
  end

  def sections
    { :default => '/', :profile => '/profile', :account => '/my_account',
      :gallery => '/galleries', :sale => '/sales', :admin => '/admin' }
  end

  def current_section
    case params[:controller]
    when 'admin' then sections[:admin]
    when 'admin/flagged_images' then sections[:admin]
    when 'admin/flagged_users' then sections[:admin]
    when 'admin/members' then sections[:admin]
    when 'admin/spotlights' then sections[:admin]
    when 'users' then sections[:account]
    when 'galleries' then sections[:gallery]
    when 'sales' then sections[:sale]
    when 'profiles' then
      if params[:action]=='show' && current_user?(params[:user_id])
        sections[:default]
      else
        sections[:profile]
      end
    when 'images' then
      case params[:action]
      when 'index' then sections[:gallery]
      else sections[:default]
      end
    else
      sections[:default]
    end
  end

  def private_links_options(active = sections[:default])
    options = [["My UPLO", sections[:default]], ['My Profile', sections[:profile]],
      ["My Account", sections[:account]], ["My Galleries", sections[:gallery]],
      ["My Sales", sections[:sale]]]
    options << ["Admin", sections[:admin]] if current_user.admin?
    options_for_select(options, active)
  end

  def state_options(state = nil)
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
      'New Jersey' => 'NJ', 'New Mexico' => 'NM', 'Nevada' => 'NV', 'New York' => Order::REGION_TAX[:newyork][:state_code],
      'Ohio' => 'OH', 'Oklahoma' => 'OK', 'Oregon' => 'OR',
      'Pennsylvania' => 'PA', 'Puerto Rico' => 'PR', 'Palau' => 'PW',
      'Rhode Island' => 'RI',
      'South Carolina' => 'SC', 'South Dakota' => 'SD',
      'Tennessee' => 'TN', 'Texas' => 'TX',
      'Utah' => 'UT',
      'Virginia' => 'VA', 'Virgin Islands' => 'VI', 'Vermont' => 'VT',
      'Washington' => 'WA', 'Wisconsin' => 'WI', 'West Virginia' => 'WV', 'Wyoming' => 'WY',
      'Military Americas' => 'AA', 'Military Europe/ME/Canada' => 'AE', 'Military Pacific' =>  'AP'
    }, state)
  end

  def popular_sort_options
    options_for_select([["Most Views", "#"]])
  end

  def redirect_back_url
    url = session[:back_url].nil? ? root_url : session[:back_url]
    return url
  end

  def set_current_tab(item)
    (current_tab.to_s == item.to_s) ? "current" : ""
  end

  # assign the current tab based on the given name, default to dashboard
  def current_tab
    @current_tab ||= "popular"
  end

  def render_pagination(data_source, paging_params = {}, options = {})
    return nil if data_source.blank?
    will_paginate(data_source, options.merge({
      :previous_label => empty_space,
      :next_label => empty_space,
      :param_name => "page",
      :params => paging_params
    }))
  end

  def empty_space
    "&nbsp".html_safe
  end

  def gender_options
    [ [I18n.t("common.male"), 0],
      [I18n.t("common.female"), 1]
    ]
  end

  def line_item_additional_class(index, max_item_per_line)
    last_column_index = max_item_per_line - 1
    additional_class = []
    additional_class << 'no-padding-left' if (index % max_item_per_line == 0)
    additional_class << 'no-padding-right' if (index % max_item_per_line == last_column_index)
    additional_class << 'no-padding-top' if (index / max_item_per_line == 0)

    return additional_class.join(' ')
  end

  def current_user?(user_id)
    user_id == current_user.try(:id)
  end

  def pluralize_without_count(count, noun)
    count == 1 ? "#{noun}" : "#{noun.pluralize}"
  end

  def search_filter_options(selected = Image::SEARCH_TYPE)
    options_for_select({'Photos' => Image::SEARCH_TYPE, 'Users' => User::SEARCH_TYPE}, selected)
  end

  def search_sort_options(type = Image::SEARCH_TYPE, selected=nil)
    type = Image::SEARCH_TYPE if type.blank?
    if type == Image::SEARCH_TYPE
      selected = Image::SORT_OPTIONS[:recent] if selected.blank?
      options_for_select({
        'Recent Uploads' => Image::SORT_OPTIONS[:recent],
        'Most Views' => Image::SORT_OPTIONS[:view],
        'Spotlight Images' => Image::SORT_OPTIONS[:spotlight]
      }, selected)
    else
      selected = User::SORT_OPTIONS[:name] if selected.blank?
      options_for_select({
        'Best Match' => User::SORT_OPTIONS[:name],
        'Date Joined' => User::SORT_OPTIONS[:date_joined]
      }, selected)
    end
  end

  # Return the first full error message for the given attribute.
  def first_error_message_for(resource, attribute)
    return nil if resource.blank? || attribute.blank?

    message = resource.errors[attribute].first
    unless message.blank?
      if resource.errors.respond_to?(:full_message)
        message = resource.errors.full_message(attribute, message)
      else
        message = full_error_message_for(resource, attribute, message)
      end
    end
    return message
  end

  # TODO: this method is implemented in Rails ActiveModel::Errors version >= 3.2
  def full_error_message_for(resource, attribute, message)
    return message if attribute == :base
    attr_name = attribute.to_s.gsub('.', '_').humanize
    attr_name = resource.class.human_attribute_name(attribute, :default => attr_name)
    I18n.t(:"errors.format", {
      :default   => "%{attribute} %{message}",
      :attribute => attr_name,
      :message   => message
    })
  end

  def yes_or_no(value)
    value ? t(:'yes') : t(:'no')
  end

  def toggle_hidden_by_admin_link(image)
    html_options = {:class => "toggle-hide", :method => :put, :remote => true}
    if image.hidden_by_admin
      link_to "UnHide Image", toggle_hidden_by_admin_admin_hidden_image_path(image), html_options
    else
      link_to "Hide Image", toggle_hidden_by_admin_admin_hidden_image_path(image), html_options
    end
  end

end
