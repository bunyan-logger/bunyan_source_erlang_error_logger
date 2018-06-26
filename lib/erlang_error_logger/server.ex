defmodule Bunyan.Source.ErlangErrorLogger.Server do

  # technically not needed, as the event handler runs in the
  # contrxt of :error_logger, but the plugin stuff assumes
  # a separate process

  use GenServer

  alias Bunyan.Source.ErlangErrorLogger.EventHandler

  def init(options) do
    swap_error_handlers(options)
    { :ok, options }
  end

  defp swap_error_handlers(options) do
    :gen_event.swap_handler(
      :error_logger,
      { :error_logger_tty_h, []      },
      { EventHandler,        options }
    )
  end

end
