defmodule Phlink.PageControllerTest do
  use Phlink.ConnCase

  @current_user %{
    id: 212,
    avatar_url: "https://avatars.githubusercontent.com/u/212?v=3",
    name: "Chris McGrath"
  }

  @session Plug.Session.init(
    store: :cookie,
    key: "_app",
    encryption_salt: "yadayada",
    signing_salt: "yadayada"
  )

  def with_session(conn) do
    conn
    |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
    |> Plug.Session.call(@session)
    |> Plug.Conn.fetch_session()
  end

  test "GET / displays homepage when user not logged in" do
    conn = get conn(), "/"
    assert html_response(conn, 200)
  end

  test "GET / redirects to new url page when user logged in" do
    conn = conn()
    |> with_session
    |> put_session(:current_user, @current_user)
    |> get("/")

    # FIXME: Session is blank, need to figure out how to put something in it
    #assert {"location", "/shorten/new"} = List.keyfind(conn.resp_headers, "location", 0)
  end
end
