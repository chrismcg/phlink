defmodule Phlink.Cache do
  alias Phlink.Cache.Mapper

  def get_url(shortcode) do
    GenServer.call(Mapper, {:get_url, shortcode})
  end

  def warm(shortcode) do
    GenServer.call(Mapper, {:warm, shortcode})
  end
end
