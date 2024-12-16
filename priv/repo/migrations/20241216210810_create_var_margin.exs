defmodule Darreck.Repo.Migrations.CreateVarMargin do
  use Ecto.Migration

  def change do
    create table(:var_margin) do
      add :instrument_uid, :string
      add :position_cost, :float
      add :var_margin, :float

      timestamps(type: :utc_datetime)
    end
  end
end
