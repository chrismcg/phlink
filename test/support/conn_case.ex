defmodule PhlinkWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import PhlinkWeb.Router.Helpers

      # TODO: See if this is still needed or can be replaced with context calls
      alias Phlink.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]

      # The default endpoint for testing
      @endpoint PhlinkWeb.Endpoint

      # Model aliases
      alias Phlink.Link
      alias Phlink.User
    end
  end


  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Phlink.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Phlink.Repo, {:shared, self()})
    end
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

end
