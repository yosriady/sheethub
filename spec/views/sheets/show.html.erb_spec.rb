require 'rails_helper'

RSpec.describe "sheets/show", :type => :view do
  before(:each) do
    @sheet = assign(:sheet, Sheet.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
