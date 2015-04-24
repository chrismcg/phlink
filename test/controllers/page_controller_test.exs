defmodule Phlink.PageControllerTest do
  use Phlink.ConnCase

  @current_user %{
    id: 212,
    avatar_url: "https://avatars.githubusercontent.com/u/212?v=3",
    name: "Chris McGrath"
  }

  test "GET / displays homepage when user not logged in" do
    conn = get conn(), "/"
    assert html_response(conn, 200)
  end

  test "GET / redirects to new url page when user logged in" do
    conn = conn()
    |> assign(:current_user, @current_user)
    |> get("/")

    assert {"location", "/shorten/new"} = List.keyfind(conn.resp_headers, "location", 0)
  end
end
