module Spree
  class Promotion
    module Actions
      class DiscountByProduct < PromotionAction
        include Spree::Core::CalculatedAdjustments
        has_many :promotion_action_product_discounts, foreign_key: :promotion_action_id
        accepts_nested_attributes_for :promotion_action_product_discounts
        has_many :adjustments, as: :source

        delegate :eligible?, to: :promotion

        validate :ensure_action_is_product
        before_destroy :deals_with_adjustments

        def perform(payload = {})
          order = payload[:order]
          return unless self.eligible? order

          # Find only the line items which have not already been adjusted by this promotion
          # HACK: Need to use [0] because `pluck` may return an empty array, which AR helpfully
          # coverts to meaning NOT IN (NULL) and the DB isn't happy about that.
          total = compute_amount order
          self.process_adjustment(total,order)
        end

        def process_adjustment(amount,order)
          return true if amount == 0

          a = order.adjustments.find_or_initialize_by(source: self,originator: self)
          a.amount= amount
          a.label= "#{Spree.t(:promotion)} (#{promotion.name})"
          a.save
          true
        end


        # Ensure a negative amount which does not exceed the sum of the order's
        # item_total and ship_total
        def compute_amount(order)
          total = 0
          order.line_items.find_each do |line_item|
            product_discount = promotion_action_product_discounts.where(product_id: line_item.variant.product.id)
            next if product_discount.empty?
            #variant_price = promotion_action_product_discounts.where(variant: line_item.variant.product.id).first
            total += product_discount.last.discount * line_item.quantity
          end
          -total
        end

        # Receives an adjustment +source+ (here a PromotionAction object) and tells
        # if the order has adjustments from that already
        def promotion_credit_exists?(adjustable)
          self.adjustments.where(:adjustable_id => adjustable.id).exists?
        end

        private
          # Tells us if there if the specified promotion is already associated with the line item
          # regardless of whether or not its currently eligible. Useful because generally
          # you would only want a promotion action to apply to line item no more than once.

          def ensure_action_is_product
            promotion_action_product_discounts.each do |p|
              if p.discount < 0
                self.errors.add(:promotion_action_product_discount_attributes_amount,"shold be a number above zero")
                return false
              end
            end
            false
          end

          def deals_with_adjustments
            self.adjustments.each do |adjustment|
              if adjustment.adjustable && adjustment.adjustable.complete?
                adjustment.originator = nil
                adjustment.save
              else
                adjustment.destroy
              end
            end
          end
      end
    end
  end
end
