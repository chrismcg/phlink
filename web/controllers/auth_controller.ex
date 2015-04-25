defmodule Phlink.AuthController do
  use Phlink.Web, :controller
  alias Phlink.User

  plug :action

  def index(conn, _params) do
    redirect conn, external: GitHub.authorize_url!
  end

  def callback(conn, %{"code" => code}) do
    github_user = GitHub.get_user(code)
    %{"name" => name, "id" => github_id, "avatar_url" => avatar_url} = github_user

    user = Repo.one(from u in User, where: u.github_id == ^github_id)

    conn
    |> handle_callback(user, name, github_id, avatar_url, github_user)
    |> redirect(to: "/")
  end

  defp handle_callback(conn, nil, name, github_id, avatar_url, github_user) do
    changeset = User.changeset(%User{}, %{
      name: name,
      github_id: github_id,
      avatar_url: avatar_url,
      github_user: github_user
    })

    if changeset.valid? do
      user = Repo.insert(changeset)
      put_user_in_session(conn, user)
    else
      conn
      |> put_flash(:error, "Couldn't login with GitHub :(")
    end
  end
  defp handle_callback(conn, user, _name, _github_id, _avatar_url, _github_user) do
    put_user_in_session(conn, user)
  end

  defp put_user_in_session(conn, user) do
    conn
    |> put_session(:current_user, %{
      id: user.id,
      name: user.name,
      avatar_url: user.avatar_url
    })
  end
end
