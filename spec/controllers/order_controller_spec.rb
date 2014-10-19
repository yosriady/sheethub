require 'rails_helper'

RSpec.describe OrderController, :type => :controller do

  describe "GET paypal_checkout" do
    it "returns http success" do
      get :paypal_checkout
      expect(response).to be_success
    end
  end

  describe "GET new" do
    it "returns http success" do
      get :new
      expect(response).to be_success
    end
  end

  describe "GET create" do
    it "returns http success" do
      get :create
      expect(response).to be_success
    end
  end

end
