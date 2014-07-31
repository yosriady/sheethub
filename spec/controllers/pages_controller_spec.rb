require 'rails_helper'

RSpec.describe PagesController, :type => :controller do

  describe "GET about" do
    it "returns http success" do
      get :about
      expect(response).to be_success
    end
  end

  describe "GET terms" do
    it "returns http success" do
      get :terms
      expect(response).to be_success
    end
  end

  describe "GET privacy" do
    it "returns http success" do
      get :privacy
      expect(response).to be_success
    end
  end

end
