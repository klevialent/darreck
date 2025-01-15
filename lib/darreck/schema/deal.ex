defmodule Darreck.Schema.Deal do
  use Ecto.Schema

  schema "deal" do
    field :quantity, :integer
    field :price, Tiapi.Ecto.Quotation
    belongs_to :instrument, Darreck.Schema.Instrument

    timestamps(type: :utc_datetime)
  end

end
