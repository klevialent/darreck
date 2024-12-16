defmodule DarreckTiapi.VarMarginCalculator do
  import Tiapi.QuotationMath
  import Tiapi.Service

  @silver_uid "d8d006b6-fd44-4729-930a-3bc7050096bf"

  # @gold_uid "b347fe28-0d2a-45bf-b3bd-cda8a6ac64e6"


  def sum_var_margin(instrument_uid, from, to) do
    operations = get_var_margin_operations!(from, to)

    # IO.puts(operations.has_next)

    for %{child_operations: child_operations} <- operations.items,
        operation <- child_operations,
        operation.instrument_uid == instrument_uid do
      operation.payment
    end
    |> sum()
    |> to_float()
  end

  def sum_operations(instrument_uid, from, to) do
    operations = get_trade_operations!(instrument_uid, from, to)

    # IO.puts(operations.has_next)

    for operation <- operations.items do
      operation.payment
    end
    |> sum()
    |> to_float()
  end

  def position_cost(instrument_uid) do
    portfolio = get_portfolio!()
    position = Enum.find(portfolio.positions, fn pos -> pos.instrument_uid == instrument_uid end)
    margin_info = Tiapi.Service.get_futures_margin_info!(instrument_uid)
    point_price = divd(margin_info.min_price_increment_amount, margin_info.min_price_increment)

    mult([position.quantity, position.current_price, point_price]) |> to_float()
  end

  def calc() do
    {:ok, from, _} = DateTime.from_iso8601("2024-10-30 00:00:00Z")
    # {:ok, to, _} = DateTime.from_iso8601("2024-10-30 11:20:00Z")
    to = DateTime.utc_now()

    [
      vm: sum_var_margin(@silver_uid, from, to),
      op: sum_operations(@silver_uid, from, to),
    ]
  end

  def vms() do
    {:ok, date, _} = DateTime.from_iso8601("2024-12-12 00:00:00Z")
    vms(0.0, 0.0, date, DateTime.utc_now(), true)
  end

  def vms(acc_ops, acc_vms, date, now, is_past_date) when is_past_date do
    to = DateTime.add(date, 1, :day)
    acc_ops = acc_ops + sum_operations(@silver_uid, date, to)
    vm = sum_var_margin(@silver_uid, date, to)
    acc_vms = acc_vms + vm
    IO.puts("#{date |> DateTime.to_date()}: #{acc_ops |> prettify_number} #{vm |> prettify_number} #{acc_vms |> prettify_number}")
    vms(acc_ops, acc_vms, to, now, DateTime.compare(to, now) == :lt)
  end

  def vms(_, _, _, _, _), do: IO.puts(:done)

  def prettify_number(number) do
    number |> :erlang.float_to_binary(decimals: 2) |> String.pad_leading(14, " ")
  end

end
