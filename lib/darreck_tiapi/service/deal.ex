defmodule DarreckTiapi.Service.DealService do

  alias Darreck.Schema.Deal
  alias Darreck.Repo
  alias Darreck.Schema.Instrument
  alias Tiapi.Proto.OrderTrade
  alias Tiapi.Proto.OrderTrades
  alias DarreckTiapi.Service.InstrumentService

  def prepare(%OrderTrades{} = order_trades) do
    trades = Enum.reduce(order_trades.trades, %{},
      fn %OrderTrade{} = trade, acc -> map_sum(acc, trade.price, trade.quantity) end
    )
    instrument = InstrumentService.get_with_deals_on_date(order_trades.instrument_uid, Date.utc_today())
    for {price, quantity} <- trades do
      add_deal(instrument, price, quantity(order_trades.direction, quantity))
    end
  end

  def save(deals) do
    Repo.transaction(fn ->
      for deal <- deals do
        deal |> Repo.insert_or_update()
      end
    end)
  end

  defp map_sum(map, key, value) do
    Map.put(map, key, Map.get(map, key, 0) + value)
  end

  defp quantity(:ORDER_DIRECTION_BUY, quantity), do: quantity
  defp quantity(:ORDER_DIRECTION_SELL, quantity), do: -quantity

  defp add_deal(%Instrument{} = instrument, price, quantity) do
    same_deal = fn deal ->
      deal.price.units == price.units
      and  deal.price.nano == price.nano
      and deal.quantity * quantity > 0
    end
    deal = Enum.find(instrument.deals, same_deal)
    if (is_nil(deal)) do
      %Deal{
        quantity: quantity,
        price: price,
        instrument_id: instrument.id,
      } |> Deal.changeset
    else
      Deal.changeset(deal, %{quantity: deal.quantity + quantity})
    end
  end

end
