defmodule DarreckTiapi.Service.InstrumentService do

  import Ecto.Query
  alias Darreck.Repo
  alias Darreck.Schema.Instrument

  def get_with_deals_on_date(instrument_uid, date) do
    instrument = Repo.one(
      from instrument in Instrument,
      left_join: deal in assoc(instrument, :deals),
      on: fragment("?::date", deal.inserted_at) == ^date,
      where: instrument.uid == ^instrument_uid,
      preload: [deals: deal]
    )
    if is_nil(instrument) do
      create(instrument_uid)
    else
      instrument
    end
  end

  def create(instrument_uid) do
    instrument = Tiapi.Service.get_instrument_by_uid!(instrument_uid)
    %Instrument{
      figi: instrument.figi,
      name: instrument.name,
      ticker: instrument.ticker,
      type: String.to_atom(instrument.instrument_type),
      uid: instrument.uid,
      deals: [],
    }
    |> Repo.insert!()
  end

end
