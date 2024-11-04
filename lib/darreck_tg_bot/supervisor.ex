defmodule DarreckTgBot.Supervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    updates_handler =
      if Application.get_env(:darreck, :tg_bot_work_mode, :webhook) == :webhook do
        DarreckTgBot.Updates.Angler
      else
        DarreckTgBot.Updates.Poller
      end

      Supervisor.init([updates_handler], [strategy: :one_for_one])
  end

end
