defmodule DarreckTgBot.Chain.Command.Stat do

  use Telegex.Chain, {:command, :stat}

  @impl true
  def handle(%{chat: chat, text: _text} = _message, context) do
    context = %{
      context
      | payload: %{
          method: "sendMessage",
          chat_id: chat.id,
          text: DarreckTiapi.Portfolio.stat() |> DarreckTgBot.Response.PortfolioStat.response(),
          parse_mode: "html",
        }
    }

    {:done, context}
  end

end
