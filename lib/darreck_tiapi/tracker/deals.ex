defmodule DarreckTiapi.Tracker.Deals do
  import Tiapi.QuotationMath
  require Logger

  @spec start_link() :: {:ok, pid()}
  def start_link() do
    {:ok, spawn(&track/0)}
  end

  @spec track() :: :ok
  def track() do
    Logger.info("Start deals tracking")

    Tiapi.Stream.trades!(180_000)
    |> Stream.each(&process/1)
    |> Stream.run()
  end

  def process({:ok, %{payload: payload}}) do
    log_result(payload)
  end

  def process(error) do
    Logger.error("Error deals tracking #{inspect(error)}")
  end

  @spec log_result(
          {:order_trades, Tiapi.Proto.OrderTrades.t()}
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
    Logger.error("Unknown deals tracking #{inspect(unknown)}")
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
