require 'spec_helper'
require 'acceptance/_personas/user'

feature "Order fruits" do

  background do
    @user = Test::User.new(self)

    sm = ShippingMethod.create!(:zone_id => 2, :name => "SampleShippingMethod", :calculator_attributes => {type: "Calculator::FlatPercentItemTotal"})
    sm.calculator.update_attribute(:type, "Calculator::FlatPercentItemTotal")
    pm = PaymentMethod::Check.create!(:type => "PaymentMethod::Check", :name => "SamplePaymentMethod", :active => true, :environment => "test")
    @user.go_homepage

    @orange = Product.find_by_name "orange"
  end

  scenario "buy oranges" do
    @user.click @orange.name

    @user.see @orange.name, @orange.price.to_s

    @user.click "Add to cart"

    @user.click "Checkout", :within => "#container"

      @user.populate_form({"user_email" => "customer@example.com",
        "user_password" => "tops3cr3t",
        "user_password_confirmation" => "tops3cr3t"}, ".//*[@id='new_customers']")

    @user.click "Register"

    @user.populate_form "order_bill_address_attributes_firstname" => "Bob",
      "order_bill_address_attributes_lastname" => "Doe",
      "order_bill_address_attributes_address1" => "17th Street",
      "order_bill_address_attributes_city" => "NYC",
      "order_bill_address_attributes_state_id" => "New York",
      "order_bill_address_attributes_firstname" => "Bob",
      "order_bill_address_attributes_zipcode" => "12-121",
      "order_bill_address_attributes_phone" => "555-1123-1234",
      "order_use_billing" => true

    3.times { @user.click "Continue" }

    @user.see "Your order has been processed successfully"
  end

end
