
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

  defmodule DummyCollector do
    @me __MODULE__

    use GenServer
    def start_link() do
      GenServer.start_link(__MODULE__, nil, name: @me)
    end

    def stop() do
      GenServer.stop(@me)
    end

    def get_messages() do
      GenServer.call(@me, { :get_messages })
    end

    def init(_) do
      IO.inspect DummyInit: self()
      { :ok, %{ msgs: [] } }
    end

    def handle_cast({ :log, msg }, state) do
      IO.inspect here: msg
      state = %{ state | msgs: [ msg | state.msgs ] }
      IO.inspect dummy: msg
      { :noreply, state }
    end

    def handle_cast(other, state) do
      IO.inspect unexpected_cast: { other, state }
      { :noreply, state }
    end

    def handle_call( { :get_messages }, _, state) do
      { :reply, state.msgs, %{ state | msgs: [] }}
    end

    def handle_call(msg, _, _state) do
      raise "handle_call(#{inspect msg})"
    end

    def terminate(reason, state) do
      IO.inspect terminate: { reason, state }
    end
  end

ExUnit.start()
