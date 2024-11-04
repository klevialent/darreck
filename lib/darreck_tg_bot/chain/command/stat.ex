defmodule DarreckTgBot.Chain.Command.Stat do

  use Telegex.Chain, {:command, :stat}

  @impl true
  def handle(%{chat: chat, text: _text} = _message, context) do
    context = %{
      context
      | payload: %{
          method: "sendMessage",
          chat_id: chat.id,
          text: get_stat_text(),
          parse_mode: "html",
        }
    }

    {:done, context}
  end

  defp get_stat_text() do
    stat = DarreckTiapi.Portfolio.stat()

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

  Number.Delimit.number_to_delimited(1)

end
