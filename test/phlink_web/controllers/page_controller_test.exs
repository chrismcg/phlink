defmodule PhlinkWeb.PageControllerTest do
  use PhlinkWeb.ConnCase

  @current_user %{
    id: 212,
    avatar_url: "https://avatars.githubusercontent.com/u/212?v=3",
    name: "Chris McGrath"
  }

  test "GET / displays homepage when user not logged in" do
    assert build_conn()
           |> get("/")
           |> html_response(200)
  end

  test "GET / redirects to new url page when user logged in" do
    assert build_conn()
           |> assign(:current_user, @current_user)
           |> get("/")
           |> redirected_to() == "/shorten/new"
  end
end
