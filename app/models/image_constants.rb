module ImageConstants
  DEFAULT_STYLES = {
    smallest:        '66x66#',
    smaller:         '67x67#',
    small:           '68x68#',
    spotlight_small: '74x74#',
    thumb:           '155x155#',
    spotlight_thumb: '174x154#',
    profile_thumb:   '101x101#',
    medium:          '640x640>'
  }

  FILTER_OPTIONS = ['date_uploaded', 'num_of_views', 'num_of_likes']

  SALE_REPORT_TYPE = {
    :quantity => "quantity",
    :price => "price"
  }

  SEARCH_TYPE = 'images'

  SORT_OPTIONS = { :spotlight => 'spotlight', :view => 'views', :recent => 'recent'}

  SORT_CRITERIA = {
    SORT_OPTIONS[:view] => 'images.pageview desc',
    SORT_OPTIONS[:recent] => 'images.created_at desc',
    SORT_OPTIONS[:spotlight] => 'images.promoted desc'
  }
end