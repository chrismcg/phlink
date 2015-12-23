defmodule GitHub do
  @moduledoc """
  An OAuth2 strategy for GitHub.

  Taken from https://github.com/scrogson/oauth2_example/blob/master/web/oauth/git_hub.ex
  """
  use OAuth2.Strategy
  import Phlink.Router.Helpers

  # Public API

  def new do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: System.get_env("GITHUB_CLIENT_ID"),
      client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
      redirect_uri: auth_url(Phlink.Endpoint, :callback),
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token"
    ])
  end

  @doc """
  URL for GitHub OAuth with minimum permissions
  """
  def authorize_url!(params \\ []) do
    new()
    |> put_param(:scope, "")
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], headers \\ []) do
    OAuth2.Client.get_token!(new(), params, headers)
  end

  @doc """
  Fetch the GitHub user details given an authorization code
  """
  def get_user(code) do
    %{status_code: 200, body: github_user} =
      GitHub.get_token!(code: code)
      |> OAuth2.AccessToken.get!("/user")
    github_user
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
