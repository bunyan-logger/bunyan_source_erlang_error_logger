defmodule Bunyan.Source.ErlangErrorLogger.State do

  alias Bunyan.Source.ErlangErrorLogger

  defstruct(
    collector: nil,
    name:      nil
  )

  @valid_options [
    :name,
  ]

  def from(options) do
    import Bunyan.Shared.Options

    validate_legal_options(options, @valid_options, ErlangErrorLogger)

    %__MODULE__{
      name: options[:name] || ErlangErrorLogger
    }
  end
end
