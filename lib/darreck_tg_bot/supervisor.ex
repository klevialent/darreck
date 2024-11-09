defmodule DarreckTgBot.Supervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
      Supervisor.init([DarreckTgBot.get_updates_handler()], [strategy: :one_for_one])
  end

end
