defmodule Phlink.Repo.Migrations.CreateLink do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :url, :string
      add :shortcode, :string

      timestamps
    end

    create index(:links, [:shortcode], unique: true)
  end
end
