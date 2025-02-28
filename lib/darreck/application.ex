defmodule Darreck.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Logger

  use Application

  @impl true
  def start(_type, _args) do

    Logger.info("\n\n-------------------------- !!! START APPLICATION !!! -------------------------\n\n")

    children = [
      DarreckWeb.Telemetry,
      Darreck.Repo,
      {DNSCluster, query: Application.get_env(:darreck, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Darreck.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Darreck.Finch},
      Tiapi.Channel,
      # DarreckTiapi.Tracker.Supervisor,
      DarreckTgBot.Supervisor,
      Darreck.Scheduler,
      # Start to serve requests, typically the last entry
      DarreckWeb.Endpoint,
      Darreck.Proxy,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Darreck.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DarreckWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
