defmodule Phlink.AuthController do
  use Phlink.Web, :controller
  alias Phlink.User

  plug :action

  def index(conn, _params) do
    redirect conn, external: GitHub.authorize_url!
  end

  def callback(conn, %{"code" => code}) do
    token = GitHub.get_token!(code: code)
    github_user = OAuth2.AccessToken.get!(token, "/user")
    %{"name" => name, "id" => github_id} = github_user

    user = Repo.one(from u in User, where: u.github_id == ^github_id)

    conn
    |> handle_callback(user, token, name, github_id, github_user)
    |> redirect(to: "/")
  end

  defp handle_callback(conn, nil, token, name, github_id, github_user) do
    changeset = User.changeset(%User{}, %{name: name, github_id: github_id, github_user: github_user})
    if changeset.valid? do
      user = Repo.insert(changeset)
      put_user_in_session(conn, user, token)
    else
      conn
      |> put_flash(:error, "Couldn't login with GitHub :(")
    end
  end
  defp handle_callback(conn, user, token, _name, _github_id, _github_user) do
    put_user_in_session(conn, user, token)
  end

  defp put_user_in_session(conn, user, token) do
    conn
    |> put_session(:current_user, %{
      id: user.id,
      name: user.name,
      avatar_url: user.github_user["avatar_url"]
    })
    |> put_session(:access_token, token.access_token)
  end
end
