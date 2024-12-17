defmodule DarreckSchedule.VarMargin do
  alias Darreck.Repo
  alias DarreckTiapi.VarMarginCalculator
  alias Darreck.Schema.VarMargin, as: VarMarginEntity
  import Ecto.Query, only: [from: 2]

  @silver_uid "d8d006b6-fd44-4729-930a-3bc7050096bf"

  @spec set_position_cost() :: :ok
  def set_position_cost() do
    VarMarginEntity.changeset(%VarMarginEntity{}, %{
      instrument_uid: @silver_uid,
      position_cost: VarMarginCalculator.position_cost(@silver_uid),
      var_margin: 0.0,
    })
    |> Repo.insert()

    :ok
  end


  @spec set_var_margin() :: :ok
  def set_var_margin() do
    now = DateTime.utc_now()
    var_margin_value = VarMarginCalculator.sum_var_margin(@silver_uid, DateTime.add(now, -1, :hour), now)

    [actual, prev] = Repo.all(from e in VarMarginEntity, order_by: [desc: e.inserted_at], limit: 2)

    actual
    |> VarMarginEntity.changeset(%{var_margin: var_margin_value})
    |> Repo.update()

    diff = Float.round(actual.position_cost - prev.position_cost, 2)

    Telegex.send_message(DarreckTgBot.chat_id, "#{actual.position_cost}    #{diff}    #{var_margin_value}")

    :ok
  end

end
