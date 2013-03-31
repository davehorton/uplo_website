module ImageConstants
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