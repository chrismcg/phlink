defmodule Phlink.Cache.Mapper do
  use GenServer

  defstruct shortcodes: %{}, pids: %{}

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, %Phlink.Cache.Mapper{}}
  end

  def handle_call({:get_url, shortcode}, _from, state) do
    case cache_pid(shortcode, state) do
      nil ->
        {pid, url, state} = cache_and_update_map(shortcode, state)
        {:reply, url, state}
      pid ->
        url = Phlink.Cache.UrlCache.url(pid)
        {:reply, url, state}
    end
  end

  def handle_call({:cache_url, shortcode, url}, _from, state) do
    case cache_pid(shortcode, state) do
      # not cached so cache
      nil ->
        {pid, url, state} = cache_and_update_map(shortcode, state)
        {:reply, pid, state}
      # already cached so just reply with the pid
      pid ->
        {:reply, pid, state}
    end
  end

  def handle_info({:'DOWN', _, _, pid, _}, state) do
    shortcode_for_pid = Dict.get(state.pids, pid)
    state = %{state | shortcodes: Dict.delete(state.shortcodes, shortcode_for_pid)}
    state = %{state | pids: Dict.delete(state.pids, pid)}
    {:noreply, state}
  end

  defp cache_pid(shortcode, state) do
    Dict.get(state.shortcodes, shortcode)
  end

  defp cache_and_update_map(shortcode, state) do
    {pid, url} = get_and_cache(shortcode)
    state = %{state | shortcodes: Dict.put(state.shortcodes, shortcode, pid)}
    state = %{state | pids: Dict.put(state.pids, pid, shortcode)}
    {pid, url, state}
  end

  defp get_link_from_db(shortcode) do
    alias Phlink.Link
    alias Phlink.Repo
    import Ecto.Query, only: [from: 2]

    Repo.one(from l in Link, where: l.shortcode == ^shortcode)
  end

  defp get_and_cache(shortcode) do
    case get_link_from_db(shortcode) do
      nil -> { nil, nil }
      link ->
        {:ok, pid} = Phlink.Cache.UrlCacheSupervisor.start_child(link.url)
        Process.monitor(pid)
        { pid, link.url }
    end
  end
end
