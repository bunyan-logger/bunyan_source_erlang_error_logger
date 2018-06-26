defmodule Test.ErlangLogger.Options do

  use ExUnit.Case

  alias Bunyan.Source.ErlangErrorLogger, as: EEL

  alias Bunyan.Shared.TestHelpers.DummyCollector, as: Collector

  def start_eel(config) do
    state = EEL.state_from_config(Collector, config)
    GenServer.start(EEL.Server, state, name: EEL.Server)
  end

  def stop_eel do
    GenServer.stop(EEL.Server)
  end

  # test "collector option is required" do
  #   assert_raise RuntimeError,
  #                ~r"Missing or invalid.*collector",
  #                fn -> EEL.initialize_source(nil, []) end
  # end


  # test "collector must exist" do
  #   assert_raise RuntimeError,
  #                ~r"cannot find a collector.*Wombat"s,
  #                fn -> EEL.initialize_source(Wombat, []) end
  # end

  test "can collect an error" do
    {:ok, _pid} = Collector.start_link
    start_eel([])
    :error_logger.error_msg('boom ~p', [99])
    # wait for the cast to make it through
    :timer.sleep(10)

    assert [msg] = Collector.get_messages

    Collector.stop
    stop_eel()

    assert msg.msg == "boom 99"
  end
end
