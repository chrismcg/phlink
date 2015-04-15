defmodule Phlink.Cache.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Phlink.Cache.Mapper, []),
      supervisor(Phlink.Cache.UrlCacheSupervisor, [])
    ]

    supervise(children, strategy: :one_for_all)
  end
end
