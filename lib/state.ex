defmodule Bunyan.Source.ErlangErrorLogger.State do

  defstruct(
    collector: nil,
    name:      nil
  )

  @valid_options [
    :name,
  ]

  def from(options) do
    check_known_options(Keyword.keys(options) -- @valid_options)

    %__MODULE__{
      name: options[:name]
    }
  end



  defp check_known_options([]), do: nil
  defp check_known_options(unknown) do
    raise """

    Invalid option(s) passed to Bunyan.Source.ErlangErrorLogger: #{Enum.join(unknown, ", ")}

    Valid options are: #{Enum.join(@valid_options, ", ")}

    """
  end
end
