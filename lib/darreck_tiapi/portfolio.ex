defmodule DarreckTiapi.Stat do
  alias Tiapi.Proto.Quotation

  defstruct [
    all: %Quotation{},
    cash_without_guarantee: %Quotation{},
    cash: %Quotation{},
    cash_rub: %Quotation{},
    cash_rub_without_guarantee: %Quotation{},
    guarantee:  %Quotation{},
    bonds: %Quotation{},
    var_margin: %Quotation{},
    long_shares: %Quotation{},
    short_shares: %Quotation{},
    long_futures: %Quotation{},
    short_futures: %Quotation{},
    long_all: %Quotation{},
    short_all: %Quotation{},
    long_pinned_futures: %Quotation{},
    short_pinned_futures: %Quotation{},
  ]
end

defmodule DarreckTiapi.Portfolio do
  alias DarreckTiapi.Stat
  alias Tiapi.QuotationMath
  import Tiapi.QuotationMath
  require Logger

  @blocked [
    "f295277c-fb3a-4a47-b942-93451319fdd5",   # "9888", "Baidu"},
    "e3fb7599-e72e-4fb6-a635-558b91e8ab9e",   # "3800", "GCL Technology"},
    "e07171af-d50f-48b9-9bd6-4bf73f3b1545",   # "914",  "Anhui Conch Cement"},
    "d6b784f8-c7fd-4f12-b99b-414491868d0a",   # "3",    "Hong Kong and China Gas Co."},
    "c0f504e8-605b-4f6f-b511-6f76edc10598",   # "6865", "Flat Glass Group"},
    "bbbf75a2-f61a-4fba-99aa-c6155a9c8977",   # "9988", "Alibaba"},
    "b7ed7ac7-721c-49ec-9c5a-b8ff82688ccc",   # "288",  "WH Group"},
    "b5170ff8-aa5e-4837-8101-bd81d12a5785",   # "6185", "CanSino Biologics"},
    "95d9f627-6b0c-4a73-b85a-5b3828b1a63e",   # "6690", "Haier Smart Home"},
    "947cb9df-27b6-4af8-a951-8c5823b007cc",   # "2382", "Sunny Optical Technology"},
    "86e90a64-58d3-4bc9-921c-e963cf1e53e3",   # "1385", "Shanghai Fudan Microelectronics"},
    "7a12723a-1973-4e5e-9c30-316f9f0c0fb8",   # "1093", "CSPC Pharmaceutical"},
    "6d4a424f-4c69-4c24-b75f-4859ce422bd1",   # "2319", "China Mengniu Dairy"},
    "620e9c90-8c05-4c16-bf06-4b07c87e7639",   # "2318", "Ping An"},
    "432fcc14-cdcd-4665-938c-2eddcea1a97a",   # "9618", "JD.com"},
    "4158cc55-c051-4bb3-bf54-aacc2d3c1cf5",   # "6881", "China Galaxy Securities"},
    "414385e9-26a7-4a52-b7c0-80a684e3df22",   # "939",  "China Construction Bank"},
    "38306217-5793-454c-8f65-6a79f652b6ee",   # "3690", "Meituan"},
    "2ef8c93e-e1df-4896-81a0-50c409c3d5d8",   # "1898", "China Coal Energy"},
    "2a51f764-f6d9-4ddf-b043-39fe888d50c6",   # "1880", "China Tourism Group Duty Free"},
    "293dfdc7-2b09-4476-ba08-6eacdf3c4b44",   # "700",  "Tencent Holdings"},
    "208041c9-606f-45fa-abee-2a21936b4260",   # "9866", "NIO Inc"},
    "1db9e96b-c87c-4ce3-92e1-9fb4e87e6c3c",   # "1177", "Sino Biopharmaceutical"},
    "15866471-5eec-43e9-8638-0f3d46cb2caf",   # "3988", "Bank of China"},
    "0e2412d4-2b57-46e7-a8b8-408c9fec6bc9",   # "1",    "CK Hutchison Holdings"},
    "0c8d9e14-d60f-4e5a-8565-d0d278a8e4e4",   # "2331", "Li-Ning"},

    "7f002803-2558-4428-958c-5edc41b8e057",   # "MSST", "Мультисистема"},

    "ded712a8-9883-4f29-8de9-c9c2c92cc97b",   # "RSHE", "РСХБ – Фонд Акций развивающихся стран"},
    "72eb80d9-ffe3-4374-b9f8-aba2e1dc8c34",   # "TPAS", "PAN-ASIA"},
    "4f358064-6c73-4002-b787-ae6de05288bb",   # "TFNX", "FinTech"},
    "1066670a-12c8-4858-aea9-423a69d8fd35",   # "TIPO", "Индекс IPO"},
    "feac3792-01de-4968-95b0-8d3fd87f881a",   # "TIPO2", "Тинькофф Индекс IPO заблокированные активы"}
    "1dd5f787-7fd9-4cfb-a5eb-9658b0b931e7",   # "RU000A1071E3", "Тинькофф Индекс IPO заблокированные активы"},
    "af6fd8d3-da6a-4b3b-baff-33f5f76938f0",   # "IE00BD3QFB18", "FinEx Акции китайских компаний"},

    "f60fc857-22ee-4f96-9c58-41b1dccf80f6",   # "US1729674242", "Citigroup"},
    "a22a1263-8e1b-4546-a1aa-416463f104d3",   # "USD000UTSTOM", "Доллар США"},
  ]

  @rub_uid "a92e2e25-a698-45cc-a781-167cf465257c"    #"RUB000UTSTOM", "Российский рубль"}

  @cash_instruments [
    "1d0e01e5-148c-40e5-bb8f-1bf2d8e03c1a",   # "TPAY", "Пассивный доход"}
    "ade12bc5-07d9-44fe-b27a-1543e05bacfd",   # "LQDT", "ВИМ - Ликвидность"}
  ]

  @pinned_futures [
    "b347fe28-0d2a-45bf-b3bd-cda8a6ac64e6",   # "GLDRUBF", "GLDRUBF Золото (rub)"},
    "c300543d-aa18-4249-b110-615409dde036",   # "CNYRUBF", "CNYRUBF Юань - Рубль"},
    "d8d006b6-fd44-4729-930a-3bc7050096bf",   # "SVZ4", "SILV-12.24 Серебро"}
  ]

  @spec stat() :: Stat.t()
  def stat when true do
    portfolio = Tiapi.Service.get_portfolio!()

        stat = Enum.reduce(portfolio.positions, %Stat{},

      fn (%{instrument_uid: uid}, acc) when uid in @blocked ->
        acc

      (%{instrument_uid: @rub_uid} = position, acc) ->
        acc
        |> add(:cash, calc_position_price(position))
        |> add(:cash_rub, calc_position_price(position))

      (%{instrument_uid: uid} = position, acc) when uid in @cash_instruments->
        add(acc, :cash, calc_position_price(position))

      (%{instrument_type: "share"} = position, acc) when position.quantity.units > 0 ->
        add(acc, :long_shares, calc_position_price(position))

      (%{instrument_type: "share"} = position, acc) when position.quantity.units < 0 ->
        add(acc, :short_shares, calc_position_price(position))

      (%{instrument_type: "futures"} = position, acc) when position.instrument_uid in @pinned_futures and position.quantity.units > 0 ->
        add_futures(acc, :long_pinned_futures, :dlong_min, position)

      (%{instrument_type: "futures"} = position, acc) when position.instrument_uid in @pinned_futures and position.quantity.units < 0 ->
        add_futures(acc, :short_pinned_futures, :dshort_min, position)

      (%{instrument_type: "futures"} = position, acc) when position.quantity.units > 0 ->
        add_futures(acc, :long_futures, :dlong_min, position)

      (%{instrument_type: "futures"} = position, acc) when position.quantity.units < 0 ->
        add_futures(acc, :short_futures, :dshort_min, position)

      (%{instrument_type: "bond"} = position, acc) ->
        add(acc, :bonds, sum(calc_position_price(position), mult(position.current_nkd, position.quantity)))

      (position, acc) ->
        instrument = Tiapi.Service.get_instrument_by_uid!(position.instrument_uid)
        Logger.error("Unknown position: #{instrument.name}, #{instrument.uid}, #{instrument.ticker}")
        acc

      end
    )

    %{stat |
      all: sum([stat.long_shares, stat.cash, stat.bonds, stat.var_margin]) |> sub(stat.short_shares) |> to_float(),
      cash_without_guarantee: sub(stat.cash, stat.guarantee) |> to_float(),
      cash_rub: to_float(stat.cash_rub),
      cash_rub_without_guarantee: sub(stat.cash_rub, stat.guarantee) |> to_float(),
      cash: to_float(stat.cash),
      guarantee: to_float(stat.guarantee),
      bonds: to_float(stat.bonds),
      var_margin: to_float(stat.var_margin),
      long_shares: to_float(stat.long_shares),
      short_shares: to_float(stat.short_shares),
      long_futures: to_float(stat.long_futures),
      short_futures: to_float(stat.short_futures),
      long_all: sum(stat.long_shares, stat.long_futures) |> to_float(),
      short_all: sum(stat.short_shares, stat.short_futures) |> to_float(),
      long_pinned_futures: to_float(stat.long_pinned_futures),
      short_pinned_futures: to_float(stat.short_pinned_futures),
    }

  end

  defp add_futures(stat, field, risk_rate_key, position) do
    margin_info = Tiapi.Service.get_futures_margin_info!(position.instrument_uid)
    instrument = Tiapi.Service.get_instrument_by_uid!(position.instrument_uid)
    quantity = QuotationMath.abs(position.quantity)
    point_price = divd(margin_info.min_price_increment_amount, margin_info.min_price_increment)
    price = mult([quantity, position.current_price, point_price])

    stat
    |> add(:guarantee, mult(Map.get(instrument, risk_rate_key), price))
    |> add(:var_margin, position.var_margin)
    |> add(field, price)
  end

  defp calc_position_price(position) do
    Tiapi.QuotationMath.abs(mult(position.current_price, position.quantity))
  end

  defp add(stat, stat_key, add) do
    %{stat | stat_key => sum(Map.get(stat, stat_key), add)}
  end
end
