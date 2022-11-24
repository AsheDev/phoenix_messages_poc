defmodule MessagesPoc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # {Task.Supervisor, name: MyApp.TaskSupervisor}, # BLAH
      # Start the Ecto repository
      MessagesPoc.Repo,
      # Start the Telemetry supervisor
      MessagesPocWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MessagesPoc.PubSub},
      MessagesPocWeb.Presence,
      # Start the Endpoint (http/https)
      MessagesPocWeb.Endpoint,
      # Start a worker by calling: MessagesPoc.Worker.start_link(arg)
      # {MessagesPoc.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MessagesPoc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MessagesPocWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
