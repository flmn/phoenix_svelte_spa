defmodule PhoenixSvelteSpa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixSvelteSpaWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:phoenix_svelte_spa, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixSvelteSpa.PubSub},
      # Start a worker by calling: PhoenixSvelteSpa.Worker.start_link(arg)
      # {PhoenixSvelteSpa.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixSvelteSpaWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixSvelteSpa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixSvelteSpaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
