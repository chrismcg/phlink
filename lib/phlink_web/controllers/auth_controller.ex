defmodule PhlinkWeb.AuthController do
  @moduledoc """
  Handle OAuth to GitHub
  """
  use PhlinkWeb, :controller
  alias Phlink.Accounts.User

  @doc """
  Take the user to github to authorize phl.ink and login
  """
  def index(conn, _params) do
    redirect conn, external: github().authorize_url!
  end

  @doc """
  Try and find the user by thier GitHub id. Creates a new user record if we
  haven't seen them before. Add user details to the session once they're
  logged in.
  """
  def callback(conn, %{"code" => code}) do
    github_user = github().get_user(code)
    %{
      "name" => name,
      "id" => github_id,
      "avatar_url" => avatar_url
    } = github_user

    user = get_user_from_github_id(github_id)

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
      user = Repo.insert!(changeset)
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

  defp github do
    Application.get_env :phlink, :github_api
  end

  defp get_user_from_github_id(github_id) do
    Repo.one(from u in User, where: u.github_id == ^github_id)
  end
end
