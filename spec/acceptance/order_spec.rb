require 'spec_helper'

#  Customer should be able to buy product from products catalogue. 
#  To accomplish transaction, customer should proceed from cart to checkout, 
#  create new or log into existing account, supply shipping information and 
#  information regarding payments. The transaction can be treated as accomplished 
#  when payment has been registered in the system and merchandise has been shipped 
#  to the customer. The main value of this functionality is revenue generation.

feature "Order fruits" do

  background do
    sm = ShippingMethod.create!(:zone_id => 2, :name => "SampleShippingMethod", :calculator_attributes => {type: "Calculator::FlatPercentItemTotal"})
    sm.calculator.update_attribute(:type, "Calculator::FlatPercentItemTotal")
    pm = PaymentMethod::Check.create!(:type => "PaymentMethod::Check", :name => "SamplePaymentMethod", :active => true, :environment => "test")
    visit "/"

    @orange = Product.find_by_name "orange"
  end

  scenario "buy oranges" do
    click_on @orange.name

    page.body.should match @orange.name
    page.body.should match @orange.price.to_s

    click_on "Add to cart"

    click_on "Checkout"

    within("#new_customers") do
      fill_in "user_email", :with => "customer@example.com"
      fill_in "user_password", :with => "tops3cr3t"
      fill_in "user_password_confirmation", :with => "tops3cr3t"
    end

    click_on "Register"

    fill_in "order_bill_address_attributes_firstname", :with => "Bob"
    fill_in "order_bill_address_attributes_lastname", :with => "Doe"
    fill_in "order_bill_address_attributes_address1", :with => "17th Street"
    fill_in "order_bill_address_attributes_city", :with => "NYC"
    select "New York", :from => "order_bill_address_attributes_state_id"
    fill_in "order_bill_address_attributes_firstname", :with => "Bob"
    fill_in "order_bill_address_attributes_zipcode", :with => "12-121"
    fill_in "order_bill_address_attributes_phone", :with => "555-1123-1234"
    check "order_use_billing"

    3.times { click_on "Continue" }

    page.body.should match "Your order has been processed successfully"
  end

end
