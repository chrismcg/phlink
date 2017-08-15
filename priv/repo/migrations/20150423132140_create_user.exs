defmodule Phlink.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :github_id, :integer
      add :github_user, :map

      timestamps()
    end

    create index(:users, [:github_id], unique: true)
  end
end
