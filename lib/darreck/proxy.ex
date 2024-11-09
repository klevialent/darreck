defmodule Darreck.Proxy do
  use MainProxy.Proxy

  @impl MainProxy.Proxy
  def backends do
    [
      %{
        verb: ~r/post/i,
        path: ~r{^/updates_hook$},
        plug: Telegex.Hook.Server,
        opts: %{
          handler_module: DarreckTgBot.get_updates_handler(),
          secret_token: Application.get_env(:darreck, DarreckTgBot.Updates.Angler)[:token],
        },
      },
      %{
        phoenix_endpoint: DarreckWeb.Endpoint,
      },
    ]
  end
end
