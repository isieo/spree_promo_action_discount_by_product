class CreateSpreePromotionActionProductDiscounts < ActiveRecord::Migration
  def change
    create_table :spree_promotion_action_product_discounts do |t|
      t.integer :promotion_action_id
      t.integer :product_id
      t.decimal :discount, default: 0

      t.timestamps
    end
  end
end
