defmodule Phlink.AuthControllerTest do
  use Phlink.ConnCase
  import Mock

  test "GET /auth redirects to github" do
    conn = get conn(), "/auth"
    assert html_response(conn, 302)
    expected_url = GitHub.authorize_url!
    assert {"location", ^expected_url} = List.keyfind(conn.resp_headers, "location", 0)
  end

  test "GET /auth/callback?code=<code> sets the current user and access token" do
    token = %{access_token: "test_token"}
    with_mock GitHub, [get_token!: fn(code: "test") -> token end] do
      with_mock OAuth2.AccessToken, [get!: fn(token , "/user") -> "user" end] do
        conn = get conn(), "/auth/callback?code=test"
        assert html_response(conn, 302)
        assert {"location", "/"} = List.keyfind(conn.resp_headers, "location", 0)
      end
    end
  end
end
