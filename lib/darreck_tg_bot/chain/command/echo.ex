defmodule DarreckTgBot.Chain.Command.Echo do
  @moduledoc false

  use Telegex.Chain, :message

  @impl true
  def match?(%{text: "/echo "<>_text} = _message, _context), do: true

  @impl true
  def match?(_message, _context), do: false

  @impl true
  def handle(%{chat: chat, text: "/echo "<>text} = _message, context) do
    context = %{
      context
      | payload: %{
          method: "sendMessage",
          chat_id: chat.id,
          text: "#{text} #{text}"
        }
    }

    {:done, context}
  end
end
