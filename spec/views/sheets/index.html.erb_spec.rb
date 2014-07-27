require 'rails_helper'

RSpec.describe "sheets/index", :type => :view do
  before(:each) do
    assign(:sheets, [
      Sheet.create!(),
      Sheet.create!()
    ])
  end

  it "renders a list of sheets" do
    render
  end
end
