
defmodule TestHelpers do

  alias Bunyan.Shared.Level

  @xmas_seconds (:calendar.datetime_to_gregorian_seconds({{2020, 12, 25}, { 12, 34, 56 }}) - 62167219200)
  @xmas { div(@xmas_seconds, 1_000_000), rem(@xmas_seconds, 1_000_000), 123_456 }

  @debug Level.of(:debug)
  # @info  Level.of(:info)
  # @warn  Level.of(:warn)
  # @error Level.of(:error)


  def msg(level \\ @debug, msg, extra \\ nil, timestamp \\ @xmas, pid \\ :a_pid, node \\ :a_node) do
    %Bunyan.Shared.LogMsg{
      level:     level,
      msg:       msg,
      extra:     extra,
      timestamp: timestamp,
      pid:       pid,
      node:      node
    }
  end
end



ExUnit.start()
