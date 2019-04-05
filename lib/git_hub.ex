defmodule GitHub do
  @moduledoc """
  An OAuth2 strategy for GitHub.

  Taken from https://github.com/scrogson/oauth2_example/blob/master/web/oauth/github.ex
  """
  use OAuth2.Strategy

  import PhlinkWeb.Router.Helpers

  # TODO: Put the github config in application config so that all happens in one place
  def client do
    OAuth2.Client.new(
      strategy: __MODULE__,
      client_id: System.get_env("GITHUB_CLIENT_ID"),
      client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
      redirect_uri: auth_url(PhlinkWeb.Endpoint, :callback),
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token"
    )
  end

  @doc """
  URL for GitHub OAuth with minimum permissions
  """
  def authorize_url! do
    OAuth2.Client.authorize_url!(client(), scope: "")
  end

  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token!(client(), params, headers, opts)
  end

  @doc """
  Fetch the GitHub user details given an authorization code
  """
  def get_user(code) do
    %{status_code: 200, body: github_user} =
      GitHub.get_token!(code: code)
      |> OAuth2.Client.get!("/user")

    github_user
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("Accept", "application/json")
    |> OAuth2.Client.put_serializer("application/json", Jason)
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
