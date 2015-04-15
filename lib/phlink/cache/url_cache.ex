defmodule Phlink.Cache.UrlCache do
  use GenServer

  def start_link(url) do
    GenServer.start_link(__MODULE__, url)
  end

  def url do
    GenServer.call(__MODULE__, :url)
  end

  def init([url]) do
    {:ok, url}
  end

  def handle_call(:url, _from, url) do
    {:ok, url, url}
  end
end
