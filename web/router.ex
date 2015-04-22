defmodule Phlink.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :assign_current_user
  end

  pipeline :unshorten do
    plug :accepts, ["html"]
  end

  scope "/auth", Phlink do
    pipe_through :browser

    get "/", AuthController, :index
    get "/callback", AuthController, :callback
  end

  scope "/", Phlink do
    pipe_through :unshorten
    get "/:shortcode", LinkController, :unshorten
  end

  scope "/", Phlink do
    pipe_through :browser # Use the default browser stack

    get "/", LinkController, :new
    get "/shorten/:id", LinkController, :show
    post "/shorten", LinkController, :create
  end

  defp assign_current_user(conn, _) do
    assign(conn, :current_user, get_session(conn, :current_user))
  end
end
