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
    cache_pid = Dict.get(state, shortcode)
    case cache_pid do
      nil ->
        {pid, url} = get_and_cache(shortcode, state)
        state = Dict.put(state, shortcode, pid)
        {:reply, url, state}
      pid ->
        url = Phlink.Cache.get_url(pid)
        {:reply, url, state}
    end
  end

  defp get_link_from_db(shortcode) do
    Repo.one(from l in Link, where: l.shortcode == ^shortcode)
  end

  defp get_and_cache(shortcode, state) do
    case get_link_from_db(shortcode) do
      nil -> { state, nil } # TODO: figure out how to cache nil
      link ->
        {:ok, pid} = Phlink.Cache.store_url(link.url)
        { pid, link.url }
    end
  end
end
