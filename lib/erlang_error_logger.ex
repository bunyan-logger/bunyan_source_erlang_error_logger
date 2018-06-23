defmodule Bunyan.Source.ErlangErrorLogger do

  @behaviour Bunyan.Shared.Readable

  alias Bunyan.Source.ErlangErrorLogger.{ EventHandler, State }

  def initialize_source(collector, options) do
    validate_collector(collector)
    state = State.from(options)
            |> Map.put(:collector, collector)
    swap_error_handlers(state)
  end

  defp swap_error_handlers(options) do
    :gen_event.swap_handler(
      :error_logger,
      { :error_logger_tty_h, []      },
      { EventHandler,        options }
    )
  end

  defp validate_collector(nil) do
    raise """

    Missing or invalid `collector:` option in the
    configuration for  Bunyan.Source.ErlangErrorLogger.

    """
  end

  defp validate_collector(collector) when is_atom(collector) do
    case Process.whereis(collector) do
      nil ->
        raise """

        Bunyan.Source.ErlangErrorLogger cannot find a collector
        named #{inspect collector}. Please check the `collector:`
        option in the appropriate section of your Bunyan config.

        """
      pid ->
        validate_collector(pid)
      end
    end

  defp validate_collector(pid) when is_pid(pid) do
    cond do
      Process.alive?(pid) ->
        :ok

      true ->
        raise """

        Bunyan.Source.ErlangErrorLogger cannot find a collector
        at pid #{inspect pid}. Please check the `collector:`
        option in the appropriate section of your Bunyan config.

        """
    end
  end

end
