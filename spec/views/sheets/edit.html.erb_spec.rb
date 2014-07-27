require 'rails_helper'

RSpec.describe "sheets/edit", :type => :view do
  before(:each) do
    @sheet = assign(:sheet, Sheet.create!())
  end

  it "renders the edit sheet form" do
    render

    assert_select "form[action=?][method=?]", sheet_path(@sheet), "post" do
    end
  end
end
