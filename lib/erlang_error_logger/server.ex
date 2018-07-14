defmodule Bunyan.Source.ErlangErrorLogger.Server do

  # technically not needed, as the event handler runs in the
  # context of :error_logger, but the plugin stuff assumes
  # a separate process

  use GenServer

  alias Bunyan.Source.ErlangErrorLogger.EventHandler

  def start_link(options) do
    { :ok, _pid } = GenServer.start_link(__MODULE__, options)
  end

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
