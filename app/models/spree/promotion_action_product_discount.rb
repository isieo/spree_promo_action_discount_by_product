module Spree
  class PromotionActionProductDiscount < ActiveRecord::Base
    belongs_to :promotion_action, class_name: 'Spree::Promotion::Actions::DiscountByProduct'
    belongs_to :product, class_name: 'Spree::Product'
    attr_accessor :variant_id

    def variant_id=(value)
      variant = Spree::Variant.find value
      self.product = variant.product
    end

    def variant_id
      return nil if !self.product
      self.product.master
    end
  end
end
