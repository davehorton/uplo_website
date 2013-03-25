INVITE_REQUEST_EMAIL = "patrick@uplo.com"

PER_TAX = 0
SHIPPING_FEE = 15
RESOURCE_LIMIT = {:size => 250, :unit => "MB"}
HELD_AVATARS_NUMBER = 5

PRINT_RESOLUTION = 150
RECTANGULAR_RATIO = 1.2

IMAGE_SQUARE_PRINTED_SIZES   = ['5x5',  '8x8', '12x12', '20x20']
IMAGE_PORTRAIT_PRINTED_SIZES = ['5x7', '8x10', '12x16', '20x24']

PRINTED_SIZES = {
  :square => IMAGE_SQUARE_PRINTED_SIZES,
  :rectangular => IMAGE_PORTRAIT_PRINTED_SIZES
}

TIERS = { :tier_1 => '1', :tier_2 => '2', :tier_3 => '3', :tier_4 => '4' }


IMAGE_COMMISSIONS = {
  TIERS[:tier_1] => 0.3,
  TIERS[:tier_2] => 0.35,
  TIERS[:tier_3] => 0.4,
  TIERS[:tier_4] => 0.5,
}

MOULDING = {
  :print => '1', #print only (Gloss)
  :print_luster => '8', #print only (Luster)
  :canvas => '2',
  :plexi => '3',
  :black => '4',
  :white => '5',
  :light_wood => '6',
  :rustic_wood => '7'
}

MOULDING_DISPLAY = {
  MOULDING[:print] => 'Print Only (Gloss)',
  MOULDING[:print_luster] => 'Print Only (Luster)',
  MOULDING[:canvas] => 'Canvas',
  MOULDING[:plexi] => 'Plexi',
  MOULDING[:black] => 'Black',
  MOULDING[:white] => 'White',
  MOULDING[:light_wood] => 'Light Wood',
  MOULDING[:rustic_wood] => 'Rustic Wood'
}

MOULDING_SIZES_CONSTRAIN = {
  MOULDING[:rustic_wood] => [IMAGE_SQUARE_PRINTED_SIZES[0], IMAGE_PORTRAIT_PRINTED_SIZES[0]]
}

MOULDING_PRICES = {
  MOULDING[:print] => {
    TIERS[:tier_1] => {
      IMAGE_SQUARE_PRINTED_SIZES[0] => 20, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 20,
      IMAGE_SQUARE_PRINTED_SIZES[1] => 30, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 30,
      IMAGE_SQUARE_PRINTED_SIZES[2] => 100, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 100,
      IMAGE_SQUARE_PRINTED_SIZES[3] => 200, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 200
    },
    TIERS[:tier_2] => {
      IMAGE_SQUARE_PRINTED_SIZES[0] => 40, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 40,
      IMAGE_SQUARE_PRINTED_SIZES[1] => 60, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 60,
      IMAGE_SQUARE_PRINTED_SIZES[2] => 200, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 200,
      IMAGE_SQUARE_PRINTED_SIZES[3] => 400, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 400
    },
    TIERS[:tier_3] => {
      IMAGE_SQUARE_PRINTED_SIZES[0] => 160, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 160,
      IMAGE_SQUARE_PRINTED_SIZES[1] => 240, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 240,
      IMAGE_SQUARE_PRINTED_SIZES[2] => 800, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 800,
      IMAGE_SQUARE_PRINTED_SIZES[3] => 1600, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 1600
    },
    TIERS[:tier_4] => {
      IMAGE_SQUARE_PRINTED_SIZES[0] => 480, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 480,
      IMAGE_SQUARE_PRINTED_SIZES[1] => 720, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 720,
      IMAGE_SQUARE_PRINTED_SIZES[2] => 2400, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 2400,
      IMAGE_SQUARE_PRINTED_SIZES[3] => 4800, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 4800
    }
  },

  MOULDING[:print_luster] => MOULDING[:print],

  MOULDING[:canvas] => {
    TIERS[:tier_1] => {
      IMAGE_SQUARE_PRINTED_SIZES[0] => 30, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 30,
      IMAGE_SQUARE_PRINTED_SIZES[1] => 40, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 40,
      IMAGE_SQUARE_PRINTED_SIZES[2] => 80, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 80,
      IMAGE_SQUARE_PRINTED_SIZES[3] => 125, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 125
    },
    TIERS[:tier_2] => {
      IMAGE_SQUARE_PRINTED_SIZES[0] => 60, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 60,
      IMAGE_SQUARE_PRINTED_SIZES[1] => 80, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 80,
      IMAGE_SQUARE_PRINTED_SIZES[2] => 160, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 160,
      IMAGE_SQUARE_PRINTED_SIZES[3] => 250, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 250
    },
    TIERS[:tier_3] => {
      IMAGE_SQUARE_PRINTED_SIZES[0] => 240, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 240,
      IMAGE_SQUARE_PRINTED_SIZES[1] => 320, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 320,
      IMAGE_SQUARE_PRINTED_SIZES[2] => 640, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 640,
      IMAGE_SQUARE_PRINTED_SIZES[3] => 1000, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 1000
    },
    TIERS[:tier_4] => {
      IMAGE_SQUARE_PRINTED_SIZES[0] => 720, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 720,
      IMAGE_SQUARE_PRINTED_SIZES[1] => 960, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 960,
      IMAGE_SQUARE_PRINTED_SIZES[2] => 1920, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 1920,
      IMAGE_SQUARE_PRINTED_SIZES[3] => 3000, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 3000
    }
  },

  MOULDING[:plexi] => {
    TIERS[:tier_1] => {
      IMAGE_SQUARE_PRINTED_SIZES[0] => 40, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 40,
      IMAGE_SQUARE_PRINTED_SIZES[1] => 50, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 50,
      IMAGE_SQUARE_PRINTED_SIZES[2] => 100, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 100,
      IMAGE_SQUARE_PRINTED_SIZES[3] => 200, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 200
    },
    TIERS[:tier_2] => {
      IMAGE_SQUARE_PRINTED_SIZES[0] => 80, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 80,
      IMAGE_SQUARE_PRINTED_SIZES[1] => 100, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 100,
      IMAGE_SQUARE_PRINTED_SIZES[2] => 200, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 200,
      IMAGE_SQUARE_PRINTED_SIZES[3] => 400, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 400
    },
    TIERS[:tier_3] => {
      IMAGE_SQUARE_PRINTED_SIZES[0] => 320, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 320,
      IMAGE_SQUARE_PRINTED_SIZES[1] => 400, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 400,
      IMAGE_SQUARE_PRINTED_SIZES[2] => 800, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 800,
      IMAGE_SQUARE_PRINTED_SIZES[3] => 1600, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 1600
    },
    TIERS[:tier_4] => {
      IMAGE_SQUARE_PRINTED_SIZES[0] => 960, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 960,
      IMAGE_SQUARE_PRINTED_SIZES[1] => 1200, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 1200,
      IMAGE_SQUARE_PRINTED_SIZES[2] => 2400, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 2400,
      IMAGE_SQUARE_PRINTED_SIZES[3] => 4800, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 4800
    }
  },

  MOULDING[:black] => nil,

  MOULDING[:white] => nil,

  MOULDING[:light_wood] => nil,

  MOULDING[:rustic_wood] => nil
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
