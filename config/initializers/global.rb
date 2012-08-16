# Application Constants/Configuration
PER_TAX = 0.05
IMAGE_MOULDING_DISCOUNT = 0.05
SHIPPING_FEE = 15
RESOURCE_LIMIT = {:size => 250, :unit => "MB"}
HELD_AVATARS_NUMBER = 5

RECTANGULAR_RATIO = 1.2
IMAGE_SQUARE_PRINTED_SIZES = ['5x5',  '8x8', '12x12', '20x20']
IMAGE_PORTRAIT_PRINTED_SIZES = ['5x7', '8x10', '12x16', '20x24']
# IMAGE_LANDSCAPE_PRINTED_SIZES = ['7x5', '10x8', '16x12', '24x20']

PRINT_RESOLUTION = 72

# Price config
TIER_1_PRICES = {
  IMAGE_SQUARE_PRINTED_SIZES[0] => 40, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 40,
  IMAGE_SQUARE_PRINTED_SIZES[1] => 75, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 75,
  IMAGE_SQUARE_PRINTED_SIZES[2] => 100, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 100,
  IMAGE_SQUARE_PRINTED_SIZES[3] => 250, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 250
}
TIER_2_PRICES = {
  IMAGE_SQUARE_PRINTED_SIZES[0] => 100, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 100,
  IMAGE_SQUARE_PRINTED_SIZES[1] => 125, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 125,
  IMAGE_SQUARE_PRINTED_SIZES[2] => 200, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 200,
  IMAGE_SQUARE_PRINTED_SIZES[3] => 400, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 400
}
TIER_3_PRICES = {
  IMAGE_SQUARE_PRINTED_SIZES[0] => 200, IMAGE_PORTRAIT_PRINTED_SIZES[0] => 200,
  IMAGE_SQUARE_PRINTED_SIZES[1] => 250, IMAGE_PORTRAIT_PRINTED_SIZES[1] => 250,
  IMAGE_SQUARE_PRINTED_SIZES[2] => 400, IMAGE_PORTRAIT_PRINTED_SIZES[2] => 400,
  IMAGE_SQUARE_PRINTED_SIZES[3] => 800, IMAGE_PORTRAIT_PRINTED_SIZES[3] => 800
}
