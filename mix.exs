unless function_exported?(Bunyan.Shared.Build, :__info__, 1),
do: Code.require_file("shared_build_stuff/mix.exs")

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

  def deps(_) do
    [
      bunyan:  [ bunyan_shared: ">= 0.0.0" ],
      others:  [],
    ]
  end

end
