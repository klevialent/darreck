defmodule DarreckTiapi.Tracker.Supervisor do
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      DarreckTiapi.Tracker.Deals,
      # DarreckTiapi.Tracker.DealsGS.Supervisor,
    ]
    Supervisor.init(children, [strategy: :one_for_one])
  end

end
