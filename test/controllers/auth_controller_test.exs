defmodule Phlink.AuthControllerTest do
  use Phlink.ConnCase
  import Mock

  @github_user %{
    "login" => "chrismcg",
    "id" => 212,
    "avatar_url" => "https://avatars.githubusercontent.com/u/212?v=3",
    "name" => "Chris McGrath"
  }

  test "GET /auth redirects to github" do
    assert conn()
    |> get("/auth")
    |> redirected_to() == GitHub.authorize_url!
  end

  test "GET /auth/callback?code=<code> puts the current user in the session" do
    with_mock GitHub, [get_user: fn("test") -> @github_user end] do
      conn = conn() |> get("/auth/callback?code=test")
      assert redirected_to(conn) == "/"

      current_user = get_session(conn, :current_user)
      user = Repo.one!(from u in User, select: u)

      assert current_user.id == user.id
      assert current_user.name == @github_user["name"]
      assert current_user.avatar_url == @github_user["avatar_url"]
    end
  end

  test "GET /auth/callback?code=<code> creates a user if they're not already in the db" do
    assert User.count == 0
    with_mock GitHub, [get_user: fn("test") -> @github_user end] do
      conn()
        |> get("/auth/callback?code=test")
    end
    assert User.count == 1

    user = Repo.one!(from u in User, select: u)

    assert user.name == "Chris McGrath"
    assert user.github_id == @github_user["id"]
    assert user.avatar_url == @github_user["avatar_url"]
    assert user.github_user == @github_user
  end

  test "GET /auth/callback?code=<code> uses the existing user if their github id is already in the db" do
    user = Repo.insert!(%User{name: "Test User", github_id: 212, github_user: @github_user})
    with_mock GitHub, [get_user: fn("test") -> @github_user end] do
      current_user = conn()
      |> get("/auth/callback?code=test")
      |> get_session(:current_user)
      assert current_user.id == user.id
    end
  end
end
