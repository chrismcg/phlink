defmodule Phlink.LayoutView do
  use Phlink.Web, :view

  # Use unquote as the values are available at compile time so there's no need
  # to read them every request
  def elixir_version, do: unquote(System.version)
  def phoenix_version, do: unquote(Application.spec(:phoenix, :vsn))
end
