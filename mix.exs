Code.load_file("shared_build_stuff/mix.exs")
alias Bunyan.Shared.Build

defmodule BunyanSourceErlangErrorLogger.MixProject do
  use Mix.Project

  def project() do
    Build.project(
      :bunyan_source_erlang_error_logger,
      "0.1.0",
      &deps/1,
      "Inject errors and reports from the Erlang error logger into the Bunyan distributed and pluggable logging system"
    )
  end

  def application(), do: []

  def deps(a) do
    IO.inspect a
    [
      bunyan:  [ bunyan_shared: ">= 0.0.0" ],
      others:  [],
    ]
  end

end
