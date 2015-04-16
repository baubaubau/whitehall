require 'test_helper'

class CourtsControllerTest < ActionController::TestCase

  test "index assigns @courts as only Court Organisations" do
    court = create(:court)
    get :index
    assert_equal [court], assigns(:courts)
  end

  test "index assigns @tribunals as only HMCTS Tribunals" do
    hmcts_tribunal = create(:hmcts_tribunal)
    get :index
    assert_equal [hmcts_tribunal], assigns(:hmcts_tribunals)
  end

  view_test "index links to the courts' show pages" do
    court = create(:court, name: "High Court")
    hmcts_tribunal = create(:hmcts_tribunal, name: "Lands Chamber")
    get :index

    assert_select "a[href=#{court_path(court)}]", text: "High Court"
    assert_select "a[href=#{court_path(hmcts_tribunal)}]", text: "Lands Chamber"
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
    assert_select ".page-header .logo h1 span span", text: "High Court"
    assert_select "title", text: "High Court - GOV.UK"
  end

  view_test "show renders the 'Who We Are' Govspeak block" do
    court = create(:court, name: "High Court")
    about_us = create(:about_corporate_information_page,
                      body: "High Court is a *pretty* high Court",
                      organisation: court)
    get :show, id: court
    assert_select ".what-we-do .overview", text: "High Court is a pretty high Court"
  end

  view_test "show renders the 'What We Do' Govspeak block" do
    court = create(:court, name: "High Court")
    about_us = create(:about_corporate_information_page,
                      body: "High Court is a *pretty* high Court",
                      organisation: court)
    get :show, id: court
    assert_select ".what-we-do .overview", text: "High Court is a pretty high Court"
  end

  view_test "show renders the page without Who We Are or What We Do if they don't exist" do
    court = create(:court, name: "High Court")
    get :show, id: court
    assert_select ".what-we-do", false
    assert_select ".who-we-are", false
  end
end
