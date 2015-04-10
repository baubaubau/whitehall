require 'test_helper'

class CourtsControllerTest < ActionController::TestCase

  test "index assigns @courts as only Court Organisations" do
    court = create(:court)
    get :index
    assert_equal [court], assigns(:courts)
  end

  view_test "index links to the courts' show pages" do
    court = create(:court, name: "High Court")
    get :index

    assert_select "a[href=#{court_path(court)}]"
  end
end
