defmodule Phlink.AuthController do
  use Phlink.Web, :controller

  plug :action

  def index(conn, _params) do
    redirect conn, external: GitHub.authorize_url!
  end

  def callback(conn, %{"code" => code}) do
    token = GitHub.get_token!(code: code)
    user = OAuth2.AccessToken.get!(token, "/user")
    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, token.access_token)
    |> redirect(to: "/")
  end
end
