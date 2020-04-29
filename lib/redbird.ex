defmodule Redbird do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      {Redix, {fetch_env_value(:uri), {fetch_env_value(:opts) || []}}
    ]

    opts = [strategy: :one_for_one, name: Redbird.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp fetch_env_value(key) do
    Application.get_env(:redbird, key, nil)
  end
end
