defmodule Rumbl.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :url, :string
      add :title, :string
      add :description, :text
      add :use_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:videos, [:use_id])
  end
end
