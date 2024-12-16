defmodule DarreckSchedule.VarMargin do
  alias Darreck.Repo
  alias DarreckTiapi.VarMarginCalculator
  alias Darreck.Schema.VarMargin, as: VarMarginEntity

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

    {:ok, var_margin} = VarMarginEntity
    |> Ecto.Query.last(:inserted_at)
    |> Repo.one()
    |> VarMarginEntity.changeset(%{var_margin: var_margin_value})
    |> Repo.update()

    Telegex.send_message(DarreckTgBot.chat_id, "#{var_margin.position_cost}    #{var_margin_value}")

    :ok
  end

end
