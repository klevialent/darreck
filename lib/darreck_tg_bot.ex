defmodule DarreckTgBot do

  @spec chat_id() :: String.t()
  def chat_id(), do: Application.get_env(:darreck, :tg_chat_id)

end 
