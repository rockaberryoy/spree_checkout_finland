class Spree::Gateway::CheckoutFinland < Spree::Gateway
  require 'nokogiri'
  require "rexml/document"

  BANKS = %w[nordea osuuspankki saastopankki omasp poppankki aktia sampo handelsbanken spankki alandsbanken]


  def self.get_provider(provider, order)    
    banks([provider], order).first
  end

  def self.banks(filter=BANKS, order)
    reference = order.number
    amount = (order.total * 100).to_i
    first_name = order.billing_address.first_name
    last_name = order.billing_address.last_name
    address = order.billing_address.address1
    postcode = order.billing_address.zipcode
    postoffice = order.billing_address.city
    email = order.user.email
    phone = order.billing_address.phone

    @xml = %x(php lib/php/request.php #{reference} #{amount} #{first_name} #{last_name} #{address} #{postcode} #{postoffice} #{email} #{phone} 2>&1)    
    
    doc = REXML::Document.new(@xml)
    formatter = REXML::Formatters::Pretty.new

    # Compact uses as little whitespace as possible
    formatter.compact = true
    str = ""
    formatter.write(doc, str)
        
    doc = Nokogiri::XML::DocumentFragment.parse(str)    

    banks = []

    filter.each_with_index do |bank, index|
      fields = []
      
      doc.xpath(".//trade//payments//payment//banks//#{bank}").children.each do |field|
        if field.instance_of? Nokogiri::XML::Element          
          fields << [field.name, field.children.first.text]
        end
      end

      banks[index] = {     
        :id => doc.xpath(".//trade//payments//payment//banks//#{bank}").first.name,   
        :name => doc.xpath(".//trade//payments//payment//banks//#{bank}/@name").first.value,
        :url => doc.xpath(".//trade//payments//payment//banks//#{bank}/@url").first.value,
        :icon => doc.xpath(".//trade//payments//payment//banks//#{bank}/@icon").first.value,
        :fields => fields
      }

    end        

    return banks
  end

  def source_required?
    false
  end
  
  def provider_class    
    Spree::Gateway::CheckoutFinland
  end

  def payment_source_class
    puts "payment_source_class"
    # Spree::CreditCard
    nil
  end

  def method_type    
    'checkout_finland'
  end

  def purchase(amount, transaction_details, options = {})
    puts "purchase"
    ActiveMerchant::Billing::Response.new(true, 'success', {}, {})
  end
end