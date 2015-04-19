defmodule Phlink.Cache.Mapper do
  use GenServer

  alias Phlink.Link
  alias Phlink.Repo
  import Ecto.Query, only: [from: 2]

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_url(shortcode) do
    GenServer.call(__MODULE__, {:get_url, shortcode})
  end

  def init([]) do
    {:ok, %{}}
  end

  def handle_call({:get_url, shortcode}, _from, state) do
    url = case Dict.get(state, shortcode) do
      nil ->
        case get_link_from_db(shortcode) do
          nil -> nil # TODO: figure out how to cache nil
          link ->
            pid = Phlink.Cache.UrlCacheSupervisor.start_child(link.url)
            Dict.put(state, shortcode, pid)
            link.url
        end
      pid -> Phlink.Cache.UrlCache.url(pid)
    end
    {:reply, url, state}
  end

  defp get_link_from_db(shortcode) do
    Repo.one(from l in Link, where: l.shortcode == ^shortcode)
  end
end
