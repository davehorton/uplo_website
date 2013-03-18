module ImageConstants
  SEARCH_TYPE = 'images'

  SORT_OPTIONS = { :spotlight => 'spotlight', :view => 'views', :recent => 'recent'}

  SORT_CRITERIA = {
    SORT_OPTIONS[:view] => 'pageview DESC',
    SORT_OPTIONS[:recent] => 'created_at DESC',
    SORT_OPTIONS[:spotlight] => 'promote_num DESC'
  }

  FILTER_OPTIONS = ['date_uploaded', 'num_of_views', 'num_of_likes']

  SALE_REPORT_TYPE = {
    :quantity => "quantity",
    :price => "price"
  }

  PRINTED_SIZES = {
    :square => IMAGE_SQUARE_PRINTED_SIZES,
    :rectangular => IMAGE_PORTRAIT_PRINTED_SIZES
  }

  TIERS = GlobalConstant::TIERS

  TIERS_PRICES = {
    TIERS[:tier_1] => TIER_1_PRICES,
    TIERS[:tier_2] => TIER_2_PRICES,
    TIERS[:tier_3] => TIER_3_PRICES
  }

  MOULDING = GlobalConstant::MOULDING

  PENDING_MOULDING = {
    MOULDING[:print] => false,
    MOULDING[:print_luster] => false,
    MOULDING[:canvas] => false,
    MOULDING[:plexi] => false,
    MOULDING[:black] => true,
    MOULDING[:white] => true,
    MOULDING[:light_wood] => true,
    MOULDING[:rustic_wood] => true
  }

  MOULDING_SIZES_CONSTRAIN = {
    MOULDING[:rustic_wood] => [IMAGE_SQUARE_PRINTED_SIZES[0], IMAGE_PORTRAIT_PRINTED_SIZES[0]]
  }

  # TODO: temp reset to 0, plz check with iOS & remove, also see: users api: get_moulding
  MOULDING_DISCOUNT = {
    MOULDING[:print] => 0,
    MOULDING[:print_luster] => 0,
    MOULDING[:canvas] => 0,
    MOULDING[:plexi] => 0,
    MOULDING[:black] => 0,
    MOULDING[:white] => 0,
    MOULDING[:light_wood] => 0,
    MOULDING[:rustic_wood] => 0
  }

  MOULDING_PRICES = {
    MOULDING[:print] => GlobalConstant::MOULDING_PRICES[MOULDING[:print]],
    MOULDING[:print_luster] => GlobalConstant::MOULDING_PRICES[MOULDING[:print]],
    MOULDING[:canvas] => GlobalConstant::MOULDING_PRICES[MOULDING[:canvas]],
    MOULDING[:plexi] => GlobalConstant::MOULDING_PRICES[MOULDING[:plexi]],
    MOULDING[:black] => nil,
    MOULDING[:white] => nil,
    MOULDING[:light_wood] => nil,
    MOULDING[:rustic_wood] => nil
  }

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
end