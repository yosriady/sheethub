require "rails_helper"

RSpec.describe SheetsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/sheets").to route_to("sheets#index")
    end

    it "routes to #new" do
      expect(:get => "/sheets/new").to route_to("sheets#new")
    end

    it "routes to #show" do
      expect(:get => "/sheets/1").to route_to("sheets#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/sheets/1/edit").to route_to("sheets#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/sheets").to route_to("sheets#create")
    end

    it "routes to #update" do
      expect(:put => "/sheets/1").to route_to("sheets#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/sheets/1").to route_to("sheets#destroy", :id => "1")
    end

  end
end
