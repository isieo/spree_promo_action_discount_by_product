class AddVariantIdToSpreePromotionActionProductDiscounts < ActiveRecord::Migration
  def change
    add_column :spree_promotion_action_product_discounts, :variant_id, :integer
  end
end
