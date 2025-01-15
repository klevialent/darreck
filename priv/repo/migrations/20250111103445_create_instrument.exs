defmodule Darreck.Repo.Migrations.CreateInstrument do
  use Ecto.Migration

  def change do
    create table(:instrument) do
      add :ticker, :string, null: false
      add :name, :string, null: false
      add :uid, :uuid, null: false
      add :figi, :string, null: false
      add :type, :string, null: false
      add :profit, :integer,  null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create unique_index(:instrument, [:uid])
  end
end
