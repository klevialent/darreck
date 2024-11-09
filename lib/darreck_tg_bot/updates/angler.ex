defmodule DarreckTgBot.Updates.Angler do
  use Telegex.GenAngler

  @impl true
  def on_boot do
    {:ok, user} = Telegex.Instance.fetch_me()
    # read some parameters from your env config
    env_config = Application.get_env(:darreck, __MODULE__)
    secret_token = env_config[:token]
    # delete the webhook and set it again
    Telegex.delete_webhook()
    # set the webhook (url and secret token)
    Telegex.set_webhook(env_config[:webhook_url], secret_token: secret_token)
    # specify port for web server
    # port has a default value of 4000, but it may change with library upgrades
    config = %Telegex.Hook.Config{
      server_port: env_config[:server_port],
      secret_token: secret_token
    }

    # you must return the `Telegex.Hook.Config` struct ↑

    Logger.info("Bot (@#{user.username}) is working (webhook)")

    config
  end

  @impl true
  def on_update(update) do
    DarreckTgBot.Chain.Handler.call(update, %DarreckTgBot.Chain.Context{bot: Telegex.Instance.bot()})
  end

  @impl true
  def on_failure(update, e) do
    Logger.error("Uncaught Error: #{inspect(update_id: update.update_id, error: e)}")
  end
end
