defmodule Phlink.Cache.UrlCache do
  use GenServer

  @cache_timeout 5 * 60 * 1000

  def start_link(url) do
    GenServer.start_link(__MODULE__, url)
  end

  def url(pid) do
    GenServer.call(pid, :url)
  end

  def init(url) do
    {:ok, url, @cache_timeout}
  end

  def handle_call(:url, _from, url) do
    {:reply, url, url, @cache_timeout}
  end

  def handle_info(:timeout, url) do
    {:stop, :normal, url}
  end
end
