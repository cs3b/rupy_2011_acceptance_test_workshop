require 'spec_helper'

feature "Visit index" do

  background do
    ShippingMethod.create!(:zone_id => 2, :name => "SampleShippingMethod", :calculator_attributes => {type: "Calculator::FlatPercentItemTotal"})
    PaymentMethod.create!(:type => "PaymentMethod::Check", :name => "SamplePaymentMethod", :active => true, :environment => "development")
  end

  scenario "visit index" do
    visit "/"
    sleep 5
  end

end
