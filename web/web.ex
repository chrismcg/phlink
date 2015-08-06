defmodule Phlink.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Phlink.Web, :controller
      use Phlink.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Model

      alias Phlink.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]

      alias Phlink.User
      alias Phlink.Link
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      alias Phlink.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]

      import Phlink.Router.Helpers

      alias Phlink.User
      alias Phlink.Link
      alias Phlink.Cache
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Phlink.Router.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Phlink.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]

    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
