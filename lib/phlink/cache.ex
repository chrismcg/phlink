defmodule Phlink.Cache do
  def get_url(shortcode), do: Phlink.Cache.Mapper.get_url(shortcode)
end
