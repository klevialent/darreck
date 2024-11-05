defmodule DarreckTgBot.Response.PortfolioStat do

  @spec response(DarreckTiapi.PortfolioStat.t()) :: String.t()
  def response(stat) do

"<code>
Стоимость: .....#{stat.all |> prettify_number}

Баланс:
  Лонг: ........#{stat.long_all |> prettify_number}
  Шорт: ........#{stat.short_all |> prettify_number}

Кэш:
  Доступно: ....#{stat.cash_without_guarantee |> prettify_number}
  Всего: .......#{stat.cash |> prettify_number}
  Рубли: .......#{stat.cash_rub |> prettify_number}
  ГО: ..........#{stat.guarantee |> prettify_number}
  Рубли без ГО: #{stat.cash_rub_without_guarantee |> prettify_number}
  Бонды: .......#{stat.bonds |> prettify_number}
  Вариационка: .#{stat.var_margin |> prettify_number}

Акции:
  Лонг: ........#{stat.long_shares |> prettify_number}
  Шорт: ........#{stat.short_shares |> prettify_number}

Фьючерсы:
  Лонг: ........#{stat.long_futures |> prettify_number}
  Шорт: ........#{stat.short_futures |> prettify_number}

Закрепленные: ..#{stat.long_pinned_futures |> prettify_number}
  Шорт: ........#{stat.short_pinned_futures |> prettify_number}
</code>"

  end

  defp prettify_number(number) do
    " "<>Number.Delimit.number_to_delimited(number, delimiter: "_") |> String.pad_leading(14, ".")
  end

end
