defmodule MessagesPoc.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :identifier, :string

      timestamps()
    end
  end
end
