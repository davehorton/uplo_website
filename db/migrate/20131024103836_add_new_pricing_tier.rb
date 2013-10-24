class AddNewPricingTier < ActiveRecord::Migration
  def up
    rename_column :products, :tier4_price, :tier5_price
    rename_column :products, :tier4_commission, :tier5_commission
    Image.where(:tier_id => 4).update_all(:tier_id => 5)

    rename_column :products, :tier3_price, :tier4_price
    rename_column :products, :tier3_commission, :tier4_commission
    Image.where(:tier_id => 3).update_all(:tier_id => 4)

    add_column :products, :tier3_price, :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :products, :tier3_commission, :decimal, :precision => 8, :scale => 2, :default => 0

    # insert tier 3 price for all products
    mouldings = {
      "Print Only (Gloss)" => [
                               { height: 8, width: 10, price: 150 },
                               { height: 12, width: 16, price: 400 },
                               { height: 20, width: 24, price: 800 },
                               { height: 24, width: 36, price: 1100 }
                              ],

      "Print Only (Luster)" => [
                                { height: 8, width: 10, price: 150 },
                                { height: 12, width: 16, price: 400 },
                                { height: 20, width: 24, price: 800 },
                                { height: 24, width: 36, price: 1100 }
                               ],
      "Canvas" => [
                   { height: 8, width: 10, price: 150 },
                   { height: 12, width: 16, price: 400 },
                   { height: 20, width: 24, price: 600 },
                   { height: 24, width: 36, price: 1000 }
                  ],
      "Plexi" =>  [
                   { height: 8, width: 10, price: 300 },
                   { height: 12, width: 16, price: 550 },
                   { height: 20, width: 24, price: 1000 },
                   { height: 24, width: 36, price: 1500 }
                  ]
    }

    mouldings.each do |moulding_name, sizes|
      moulding = Moulding.find_by_name(moulding_name)
      sizes.each do |options|
        size = Size.where(height: options[:height], width: options[:width]).first
        product = moulding.products.where(size_id: size.id).first
        product.update_attributes!(tier3_price: options[:price], tier3_commission: 35) if product
      end
    end

    # updating product price for tier 2 having moulding plexi
    plexi = Moulding.find_by_name("Plexi")
    sizes = [
             { height: 12, width: 16, price: 350 },
             { height: 20, width: 24, price: 600 },
             { height: 24, width: 36, price: 1000 }
            ]
    sizes.each do |options|
      size = Size.where(height: options[:height], width: options[:width]).first
      product = plexi.products.where(size_id: size.id).first
      product.update_attributes!(tier2_price: options[:price]) if product
    end
  end

  def down
    puts "irreversible migration"
  end
end
