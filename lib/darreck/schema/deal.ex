defmodule Darreck.Schema.Deal do

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias Darreck.Schema.Deal

  schema "deal" do
    field :quantity, :integer
    field :price, Tiapi.Ecto.Quotation
    belongs_to :instrument, Darreck.Schema.Instrument

    timestamps(type: :utc_datetime)
  end

  @spec changeset(%Deal{}) :: Changeset.t()
  def changeset(%Deal{} = deal) do
    changeset(%Deal{}, Map.from_struct(deal))
  end

  @spec changeset(%Deal{}, map()) :: Changeset.t()
  def changeset(%Deal{} = deal, attrs) do
    deal
    |> cast(attrs, [:quantity, :price, :instrument_id])
    |> validate_required([:quantity, :price, :instrument_id])
  end

end
