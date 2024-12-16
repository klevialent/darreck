defmodule Darreck.Schema.VarMargin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "var_margin" do
    field :instrument_uid, :string
    field :position_cost, :float
    field :var_margin, :float

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(var_margin, attrs) do
    var_margin
    |> cast(attrs, [:instrument_uid, :position_cost, :var_margin])
    |> validate_required([:instrument_uid, :position_cost, :var_margin])
  end
end
