defmodule Test.ErlangLogger.Options do

  use ExUnit.Case

  alias Bunyan.Source.ErlangErrorLogger, as: EEL

  test "collector option is required" do
    assert_raise RuntimeError,
                 ~r"Missing or invalid.*collector",
                 fn -> EEL.initialize_source(nil, []) end
  end


  test "collector must exist" do
    assert_raise RuntimeError,
                 ~r"cannot find a collector.*Wombat"s,
                 fn -> EEL.initialize_source(Wombat, []) end
  end

  test "can collect an error" do
    {:ok, pid} = DummyCollector.start_link
    EEL.initialize_source(pid, [])
    :error_logger.error_msg('boom ~p', [ 99])
    # wait for the cast to make it through
    :timer.sleep(10)

    assert [msg] = DummyCollector.get_messages
    assert msg.msg == "boom 99"
  end
end
