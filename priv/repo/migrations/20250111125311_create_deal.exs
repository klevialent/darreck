defmodule Darreck.Repo.Migrations.CreateDeal do
  use Ecto.Migration

  def change do
    create table(:deal) do
      add :quantity, :integer
      add :price, :map
      add :sum, :map
      add :instrument_id, references(:instrument)

      timestamps(type: :utc_datetime)
    end
  end
end
