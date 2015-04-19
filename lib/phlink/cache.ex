defmodule Phlink.Cache do
  def get_url(pid) when is_pid(pid), do: Phlink.Cache.UrlCache.url(pid)
  def get_url(shortcode), do: Phlink.Cache.Mapper.get_url(shortcode)

  def store_url(url), do: Phlink.Cache.UrlCacheSupervisor.start_child(url)
end
