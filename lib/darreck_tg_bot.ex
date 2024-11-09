defmodule DarreckTgBot do

  @spec chat_id() :: String.t()
  def chat_id(), do: Application.get_env(:darreck, :tg_chat_id)

  @spec get_updates_handler() :: DarreckTgBot.Updates.Angler | DarreckTgBot.Updates.Poller
  def get_updates_handler() do
      if Application.get_env(:darreck, :tg_bot_work_mode, :webhook) == :webhook do
        DarreckTgBot.Updates.Angler
      else
        DarreckTgBot.Updates.Poller
      end
  end

end
