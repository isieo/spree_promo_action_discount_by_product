module Spree
  class PromotionActionProductDiscount < ActiveRecord::Base
    belongs_to :promotion_action, class_name: 'Spree::Promotion::Actions::DiscountByProduct'
    belongs_to :variant, class_name: 'Spree::Variant'

  end
end
