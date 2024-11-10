defmodule DarreckSchedule.PortfolioStat do
  alias DarreckTgBot.Response.PortfolioStat, as: Response
  alias Darreck.Schema.PortfolioStat, as: Schema

  @spec run() :: :ok
  def run() do
    stat = DarreckTiapi.Portfolio.stat()

    Schema.changeset(%Schema{}, %{
      worth: stat.worth,
      cash: stat.cash_without_guarantee,
      long: stat.long_all,
      short: stat.short_all,
      pin: stat.long_pinned_futures,
    })
    |> Darreck.Repo.insert()


    Telegex.send_message(DarreckTgBot.chat_id, Response.do_response(stat), parse_mode: "html")
    :ok
  end
end
