defmodule DarreckSchedule.PortfolioStat do
  alias DarreckTiapi.Portfolio

  @spec run() :: :ok
  def run do
    response = Portfolio.stat() |> DarreckTgBot.Response.PortfolioStat.response()

    Telegex.send_message(DarreckTgBot.chat_id, response, parse_mode: "html")
    :ok
  end
end
