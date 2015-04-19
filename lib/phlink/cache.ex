defmodule Phlink.Cache do
  alias Phlink.Cache

  def get_url(shortcode) do
    GenServer.call(Cache.Mapper, {:get_url, shortcode})
  end

  def warm(shortcode) do
    GenServer.call(Cache.Mapper, {:warm, shortcode})
  end
end
