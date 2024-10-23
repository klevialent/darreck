defmodule Darreck.Repo do
  use Ecto.Repo,
    otp_app: :darreck,
    adapter: Ecto.Adapters.Postgres
end
