defmodule DarreckTiapi.Tracker.Deals do

  alias Tiapi.Proto.OrderTrades
  import Tiapi.QuotationMath
  import DarreckTiapi.Service.DealService
  require Logger

  @spec start_link() :: {:ok, pid()}
  def start_link() do
    {:ok, spawn(&track/0)}
  end

  @spec track() :: :ok
  def track() do
    Logger.info("Start deals tracking")

    Tiapi.Stream.trades!(180_000)
    |> Stream.each(&process_response/1)
    |> Stream.run()
  end

  defp process_response({:ok, %{payload: payload}}), do: process_payload(payload)
  defp process_response(error) do
    Logger.error("Error deals tracking response #{inspect(error)}")
  end

  @spec process_payload({:order_trades, OrderTrades.t()}) :: :ok
  defp process_payload({:order_trades, %OrderTrades{} = order_trades} = payload) do
    log_result(payload)
    prepare(order_trades) |> save()
  end

  defp process_payload(payload), do: log_result(payload)

  @spec log_result(
          {:order_trades, OrderTrades.t()}
          | {:ping, Tiapi.Proto.Ping.t()}
          | {:subscription, Tiapi.Proto.SubscriptionResponse.t()}
        ) :: :ok
  def log_result({:order_trades, deal}) do
    trades = for trade <- deal.trades do
      {date_string(trade.date_time), trade.quantity, to_float(trade.price)}
    end

    Logger.info("Deal #{inspect({deal.figi, date_string(deal.created_at), deal.direction, trades})}")
  end

  def log_result({:ping, ping}) do
    Logger.info("Ping #{inspect({date_string(ping.time), ping.stream_id})}")
  end

  def log_result({:subscription, subscription}) do
    Logger.warning("Subscription #{inspect(subscription)}")
  end

  def log_result(unknown) do
    Logger.error("Unknown deals tracking response #{inspect(unknown)}")
  end

  defp date_string(protobuf_timestamp) do
    datetime = DateTime.from_unix!(protobuf_timestamp.seconds)
    DateTime.to_string(datetime)
  end

  @spec child_spec(any()) :: %{
          id: DealsTracker,
          restart: :permanent,
          shutdown: 5000,
          start: {DarreckTiapi.Tracker.Deals, :start_link, []}
        }
  def child_spec(_opts) do
    %{
      id: DealsTracker,
      start: {__MODULE__, :start_link, []},
      shutdown: 5_000,
      restart: :permanent,
    }
  end

end
