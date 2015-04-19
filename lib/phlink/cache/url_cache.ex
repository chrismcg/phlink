defmodule Phlink.Cache.UrlCache do
  use GenServer

  def start_link(url) do
    GenServer.start_link(__MODULE__, url)
  end

  def url(pid) do
    GenServer.call(pid, :url)
  end

  def init([url]) do
    {:ok, url}
  end

  def handle_call(:url, _from, url) do
    {:ok, url, url}
  end
end
