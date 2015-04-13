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

    assert_select "a[href=#{court_path(court)}]", text: "High Court"
  end

  test "show assigns @court as requested Court" do
    court = create(:court)
    get :show, id: court
    assert_equal court, assigns(:court)
  end

  test "show renders a 404 if a non-Court organisation is requested" do
    org = create(:organisation)
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, id: org
    end
  end

  view_test "show is headed and titled with the name of the Court" do
    court = create(:court, name: "High Court")
    get :show, id: court
    assert_select "h1", text: "High Court"
    assert_select "title", text: "High Court - GOV.UK"
  end

  view_test "show renders the 'About Us' summary" do
    court = create(:court, name: "High Court")
    about_us = create(:about_corporate_information_page,
                      summary: "High Court is a pretty high Court",
                      organisation: court)
    get :show, id: court
    assert_select ".what-we-do", text: "High Court is a pretty high Court"
  end
end
