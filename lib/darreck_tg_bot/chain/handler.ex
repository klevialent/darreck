defmodule DarreckTgBot.Chain.Handler do
  use Telegex.Chain.Handler

  pipeline([
    DarreckTgBot.Chain.Command.Stat,
    DarreckTgBot.Chain.Command.Echo,
  ])

end
