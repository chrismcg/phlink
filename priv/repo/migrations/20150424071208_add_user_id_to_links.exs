defmodule Phlink.Repo.Migrations.AddUserIdToLinks do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add :user_id, references(:users)
    end
  end
end
