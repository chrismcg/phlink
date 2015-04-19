defmodule Phlink.Cache do
  alias Phlink.Cache.Mapper

  def get_url(shortcode) do
    GenServer.call(Mapper, {:get_url, shortcode})
  end

  def cache_url(shortcode, url) do
    GenServer.call(Mapper, {:cache_url, shortcode, url})
  end
end
