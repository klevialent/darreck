defmodule Darreck.Schema.Instrument do
  use Ecto.Schema
  import Ecto.Changeset

  schema "instrument" do
    field :figi, :string
    field :name, :string
    field :profit, :integer, default: 0
    field :ticker, :string
    field :type, Ecto.Enum, values: [:currency, :share, :futures, :bond, :etf, :index]
    field :uid, Ecto.UUID
    has_many :deals, Darreck.Schema.Deal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(instrument, attrs) do
    instrument
    |> cast(attrs, [:ticker, :name, :uid, :figi, :type, :profit])
    |> validate_required([:ticker, :name, :uid, :figi, :type, :profit])
    |> unique_constraint(:uid)
  end
end
