defmodule Plug.Session.REDIS do
  require IEx

  @moduledoc """
  Stores the session in a redis store.
  """

  @behaviour Plug.Session.Store

  @max_session_time 86_164 * 30

  def init(opts) do
    opts
  end

  def get(_conn, namespaced_key, _init_options) do
    case Redix.command(:redix, ["GET", namespaced_key]) do
      {:ok, value} -> {namespaced_key, value |> :erlang.binary_to_term()}
      _ -> {nil, %{}}
    end
  end

  def put(conn, nil, data, init_options) do
    put(conn, add_namespace(generate_random_key()), data, init_options)
  end

  def put(_conn, namespaced_key, data, init_options) do
    Redix.command(:redix, ["SETEX", namespaced_key, session_expiration(init_options), data])
    namespaced_key
  end

  def delete(_conn, redis_key, _init_options) do
    Redix.command(:redix, ["DEL", redis_key])
    :ok
  end

  defp add_namespace(key) do
    namespace() <> key
  end

  @default_namespace "redbird_session_"
  def namespace do
    Application.get_env(:redbird, :key_namespace, @default_namespace)
  end

  defp generate_random_key do
    :crypto.strong_rand_bytes(96) |> Base.encode64()
  end

  defp session_expiration(opts) do
    case opts[:expiration_in_seconds] do
      seconds when is_integer(seconds) -> seconds
      _ -> @max_session_time
    end
  end
end

defmodule Redbird.RedisError do
  defexception [:message]
  @base_message "Redbird was unable to store the session in redis."

  def raise(error: error, key: key) do
    message = "#{@base_message} Redis Error: #{error} key: #{key}"
    raise __MODULE__, message
  end

  def exception(message) do
    %__MODULE__{message: message}
  end
end
