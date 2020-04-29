defmodule Redbird do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      {Redix, host: fetch_env_value(:host), port: fetch_env_value(:port), name: :redix, ssl: fetch_env_value(:ssl)}
    ]

    opts = [strategy: :one_for_one, name: Redbird.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp fetch_env_value(key) do
    Application.get_env(:redbird, key, nil)
  end
end
