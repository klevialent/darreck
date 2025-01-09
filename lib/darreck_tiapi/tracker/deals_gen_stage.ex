defmodule DarreckTiapi.Tracker.DealsGS.Supervisor do

  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      DarreckTiapi.Tracker.DealsGS.Producer,
      DarreckTiapi.Tracker.DealsGS.Consumer,
    ]

    Supervisor.init(children, [strategy: :one_for_one])
  end

end

defmodule DarreckTiapi.Tracker.DealsGS.Producer do

  use GenStage
  require Logger

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Logger.info("Start deals tracking")

    {:producer, nil}
  end

  def handle_demand(demand, nil) do
    stream = Tiapi.Stream.trades!(180_000)
    handle_demand(demand, stream)
  end

  def handle_demand(_demand, stream) do
    {:noreply, stream |> Stream.take(1) |> Enum.to_list(), stream}
  end

end

defmodule DarreckTiapi.Tracker.DealsGS.Consumer do

  use GenStage
  require Logger
  alias DarreckTiapi.Tracker.Deals

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter, name: __MODULE__)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [{DarreckTiapi.Tracker.DealsGS.Producer, min_demand: 2, max_demand: 3}]}
  end

  def handle_events(events, _from, state) do
    for {:ok, %{payload: payload}} <- events, do: Deals.log_result(payload)

    {:noreply, [], state}
  end

end
