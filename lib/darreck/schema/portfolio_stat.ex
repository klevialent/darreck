defmodule Darreck.Schema.PortfolioStat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "portfolio_stat" do
    field :cash, :float
    field :long, :float
    field :pin, :float
    field :short, :float
    field :worth, :float

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(portfolio_stat, attrs) do
    portfolio_stat
    |> cast(attrs, [:worth, :cash, :long, :short, :pin])
    |> validate_required([:worth, :cash, :long, :short, :pin])
  end
end
