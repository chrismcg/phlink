ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Phlink.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Phlink.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Phlink.Repo)

