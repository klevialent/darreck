defmodule DarreckTiapi.PortfolioStat do
  alias Tiapi.Proto.Quotation

  defstruct [
    worth: %Quotation{},
    cash_without_guarantee: %Quotation{},
    cash: %Quotation{},
    guarantee:  %Quotation{},
    rub: %Quotation{},
    lqdt: %Quotation{},
    tmon: %Quotation{},
    tpay: %Quotation{},
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
  alias DarreckTiapi.PortfolioStat
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

  @rub_uid  "a92e2e25-a698-45cc-a781-167cf465257c"    #"RUB000UTSTOM", "Российский рубль"}
  @lqdt_uid "ade12bc5-07d9-44fe-b27a-1543e05bacfd"    # "LQDT", "ВИМ - Ликвидность"}
  @tmon_uid "498ec3ff-ef27-4729-9703-a5aac48d5789"    # "TMON@", "Денежный рынок"}
  @tpay_uid "1d0e01e5-148c-40e5-bb8f-1bf2d8e03c1a"    # "TPAY", "Пассивный доход"}

  @pinned_futures [
    "b347fe28-0d2a-45bf-b3bd-cda8a6ac64e6",   # "GLDRUBF", "GLDRUBF Золото (rub)"},
    "f571c2f9-e527-4581-80c2-35a64da61fd7",
    "24597b13-d0ce-4b0c-989c-d384564b5465",
    "d27431df-7e77-4a7a-9a5a-fbf21688464d",

    "c300543d-aa18-4249-b110-615409dde036",   # "CNYRUBF", "CNYRUBF Юань - Рубль"},
    "318e315a-2a87-458c-b0a3-2f61535ef0b3",
    "bf2b795a-5db9-4f79-b942-71ab26ad06ef",
    "8c43e020-dc97-48da-8088-1e1a52972195",
    "c908b853-eef2-4bb7-8dd9-69341d3a6f46",
    "9dc067df-de3c-4d90-a45a-c3ed939af998",
    "81f07a5c-99af-4b3a-a939-067e2ed3dd7a",

    "d8d006b6-fd44-4729-930a-3bc7050096bf",   # "SVZ4", "SILV-12.24 Серебро"}
    "7c06813e-a9bb-4fe1-a135-fb32da0fba05",
    "890390e9-c8ac-4a90-ad36-f328ea60fd6d",
    "483e017a-820f-4e6a-8b82-67fc736588e7",
    "51dc6277-6409-4cde-a1af-9c3b3b15f6f8",
    "bbd36bc7-168b-4a7e-865f-f2e9bde93a56",

    "48706c30-0bd7-42ad-a936-150287cd9de4",   # USDRUBF
    "8f99f804-abc1-4339-8c51-521c3e78cd13",
    "52a78271-73f1-4b83-a6e8-e06cb01eea64",
    "06aacf7e-cd14-49ee-9cde-7615231d0675",
    "9c8c4329-c5a3-4df9-a95e-561ccbb41082",
    "7d452ecf-6868-42b4-bded-5d0f8577eed1",
    "b4df2961-035a-4dcd-8372-9af0db10d2c9",
    "574d37d8-9de4-423a-9e33-b936002d8bda",
    "2dd5eb6b-7a52-4186-a0ec-9f7f6ed6fbd7",
    "76d6a73e-c555-4de6-a66d-be99d96ed449",
  ]

  @spec stat() :: PortfolioStat.t()
  def stat() do
    portfolio = Tiapi.Service.get_portfolio!()

    stat = Enum.reduce(portfolio.positions, %PortfolioStat{},

      fn (%{instrument_uid: uid}, acc) when uid in @blocked ->
        acc

      (%{instrument_uid: @rub_uid} = position, acc) ->
        add(acc, :rub, mult(position.current_price, position.quantity))

      (%{instrument_uid: @lqdt_uid} = position, acc) ->
        add(acc, :lqdt, mult(position.current_price, position.quantity))

      (%{instrument_uid: @tmon_uid} = position, acc) ->
          add(acc, :tmon, mult(position.current_price, position.quantity))

      (%{instrument_uid: @tpay_uid} = position, acc) ->
        add(acc, :tpay, mult(position.current_price, position.quantity))

      (%{instrument_type: "bond"} = position, acc) ->
        add(acc, :bonds, sum(position.current_price, position.current_nkd) |> mult(position.quantity))

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

      (position, acc) ->
        Logger.error("Unknown position: #{inspect(position)}")
        # instrument = Tiapi.Service.get_instrument_by_uid!(position.instrument_uid)
        # Logger.error("Unknown position: #{instrument.name}, #{instrument.uid}, #{instrument.ticker}")
        acc

      end
    )

    cash = sum([stat.rub, stat.lqdt, stat.tmon, stat.tpay, stat.bonds, stat.var_margin])

    %PortfolioStat{stat |
      worth: sum(cash, stat.long_shares) |> sub(stat.short_shares) |> to_float(),
      cash_without_guarantee: sub(cash, stat.guarantee) |> to_float(),
      cash: to_float(cash),
      guarantee: to_float(stat.guarantee),
      rub: to_float(stat.rub),
      lqdt: to_float(stat.lqdt),
      tmon: to_float(stat.tmon),
      tpay: to_float(stat.tpay),
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
    |> add(:guarantee, Map.get(instrument, risk_rate_key) |> mult(price))
    |> add(:var_margin, position.var_margin)
    |> add(field, price)
  end

  defp calc_position_price(position) do
    mult(position.current_price, position.quantity) |> Tiapi.QuotationMath.abs()
  end

  defp add(stat, stat_key, add) do
    %{stat | stat_key => Map.get(stat, stat_key) |> sum(add)}
  end
end
