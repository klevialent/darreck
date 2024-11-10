defmodule Darreck.Repo.Migrations.CreatePortfolioStat do
  use Ecto.Migration

  def change do
    create table(:portfolio_stat) do
      add :worth, :float
      add :cash, :float
      add :long, :float
      add :short, :float
      add :pin, :float

      timestamps(type: :utc_datetime)
    end
  end
end
