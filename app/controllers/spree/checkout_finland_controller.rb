module Spree
  class CheckoutFinlandController < StoreController

    def checkout
      @provider = Spree::Gateway::CheckoutFinland.get_provider(params[:provider], current_order)      
    end

    def confirm
      order = current_order || raise(ActiveRecord::RecordNotFound)
      order.payments.create!({
        amount: order.total,
        payment_method: payment_method
      })
      order.next
      if order.complete?
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:order_completed] = true
        session[:order_id] = nil
        redirect_to completion_route(order)
      else
        redirect_to checkout_state_path(order.state)
      end
    end

    def cancel
      flash[:notice] = Spree.t('Tapahtuma peruttu')
      order = current_order || raise(ActiveRecord::RecordNotFound)
      redirect_to checkout_state_path(order.state, checkout_finland_cancel_token: params[:token])
    end

    private

    def line_item(item)
      {
          Name: item.product.name,
          Number: item.variant.sku,
          Quantity: item.quantity,
          Amount: {
              currencyID: item.order.currency,
              value: item.price
          },
          ItemCategory: "Physical"
      }
    end

    def payment_method
      Spree::PaymentMethod.find_by_type(Spree::Gateway::CheckoutFinland.to_s)
    end

    def provider
      payment_method.provider
    end

    def payment_details items
      # This retrieves the cost of shipping after promotions are applied
      # For example, if shippng costs $10, and is free with a promotion, shipment_sum is now $10
      shipment_sum = current_order.shipments.map(&:discounted_cost).sum

      # This calculates the item sum based upon what is in the order total, but not for shipping
      # or tax.  This is the easiest way to determine what the items should cost, as that
      # functionality doesn't currently exist in Spree core
      item_sum = current_order.total - shipment_sum - current_order.additional_tax_total

      if item_sum.zero?
        # Paypal does not support no items or a zero dollar ItemTotal
        # This results in the order summary being simply "Current purchase"
        {
          OrderTotal: {
            currencyID: current_order.currency,
            value: current_order.total
          }
        }
      else
        {
          OrderTotal: {
            currencyID: current_order.currency,
            value: current_order.total
          },
          ItemTotal: {
            currencyID: current_order.currency,
            value: item_sum
          },
          ShippingTotal: {
            currencyID: current_order.currency,
            value: shipment_sum,
          },
          TaxTotal: {
            currencyID: current_order.currency,
            value: current_order.additional_tax_total
          },
          ShipToAddress: address_options,
          PaymentDetailsItem: items,
          ShippingMethod: "Shipping Method Name Goes Here",
          PaymentAction: "Sale"
        }
      end
    end

    def address_options
      return {} unless address_required?

      {
          Name: current_order.bill_address.try(:full_name),
          Street1: current_order.bill_address.address1,
          Street2: current_order.bill_address.address2,
          CityName: current_order.bill_address.city,
          Phone: current_order.bill_address.phone,
          StateOrProvince: current_order.bill_address.state_text,
          Country: current_order.bill_address.country.iso,
          PostalCode: current_order.bill_address.zipcode
      }
    end

    def completion_route(order)
      order_path(order)
    end

    def address_required?
      payment_method.preferred_solution.eql?('Sole')
    end
  end
end
