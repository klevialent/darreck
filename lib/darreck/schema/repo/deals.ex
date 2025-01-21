defmodule Darreck.Repo.Deals do

  import Ecto.Query, warn: false
  alias Darreck.Schema.Deal
  alias Darreck.Repo


  def list(page, per_page) do
    Repo.all(
      from deal in Deal,
      join: instrument in assoc(deal, :instrument),
      preload: [instrument: instrument],
      order_by: [asc: deal.id],
      offset: ^((page - 1) * per_page),
      limit: ^per_page
    )
  end

end
