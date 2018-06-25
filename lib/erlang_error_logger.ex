defmodule Bunyan.Source.ErlangErrorLogger do

  use Bunyan.Shared.Readable

  alias Bunyan.Source.ErlangErrorLogger.EventHandler

  def start(config) do
    swap_error_handlers(config)
  end

  defp swap_error_handlers(options) do
    :gen_event.swap_handler(
      :error_logger,
      { :error_logger_tty_h, []      },
      { EventHandler,        options }
    )
  end

end
