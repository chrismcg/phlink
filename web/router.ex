defmodule Phlink.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :unshorten do
    plug :accepts, ["html"]
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
end
