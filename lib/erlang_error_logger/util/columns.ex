defmodule Bunyan.Source.ErlangErrorLogger.Util.Columns do

  @paddings Enum.map(0..100, fn n -> {n, String.duplicate(" ", n)} end) |> Enum.into(%{})

  @doc """
  Take a list of 2-ples, work out the maximum width of the first entry of each,
  and then format them to th second column is left-aligned, so

      { "a", "apple" },
      { "bee", "honey" },
      { "cecil", "serpent" }

  becomes

      a:     apple
      bee:   honey
      cecil: serpent

  We can also right align the first column:

          a: apple
        bee: honey
      cecil: serpent

  Finally, if there's a lot of variation in the width of the first column, we
  can move the value onto the next line:

     a:     apple
     beautiful and tasty:
            honey
     cecil: serpent

  Options are:

  * `align: left | right`

    How to align the first column text. Default is left.

  * `separator: "..."`

    The text to put at the end of the first column text. Default is ":⊔⊔"

  * `line_end: "\n"`

    The string to put at the end of the second column, ending the line. Use "\n"
    for single spacing and "\n\n" to have a blank line between entries.

  """


  @defaults [
    align:     :left,
    separator: ":  ",
    line_end:  "\n",
  ]

  def align(tuples, options \\ [])

  def align([], _) do
    []
  end

  def align(tuples, options) do
    options = Keyword.merge(@defaults, options)
    lengths = tuples |> Enum.map(fn {one,_} -> one |> to_string() |> String.length() end) |> Enum.sort(&>=/2)
    count = length(lengths)

    IO.inspect tuples: tuples
    # isolate the top 20%, but only of there's a significant difference
    target_length = cond do
      count == 1 ->
        hd(lengths)

      true ->
        to_extract = div(count, 5) + 1
        max_length = hd(lengths)
        target_length = Enum.at(lengths, to_extract)
        if max_length > target_length + 15 do
          target_length
        else
          max_length
        end
    end

    IO.inspect target_length

    padding_length = target_length + String.length(options[:separator])

    Enum.map(tuples, &align_one_tuple(&1, target_length, padding_length, options))
    |> IO.inspect
  end

  defp align_one_tuple({ left, right }, col_one_length, padding_length, options) do
    padding = @paddings[padding_length]
    if String.length(left) > col_one_length do
      IO.inspect 111
      [ left, options[:separator], "\n", padding, maybe_indent(right, padding), options[:line_end] ]
    else
      IO.inspect 222
      [ justify(left, padding_length, options[:align] == :right, options[:separator]), maybe_indent(right, padding), options[:line_end]]
    end
  end

  defp maybe_indent({ :__double_indent__, values }, padding) do
     Enum.intersperse(values, padding)
  end

  defp maybe_indent(values, _padding) do
    values
  end

  defp justify("", length, _, _) do
    String.pad_leading("", length)
  end

  defp justify(string, length, true, separator) do
    String.pad_leading(string <> separator, length)
  end

  defp justify(string, length, _, separator) do
    String.pad_trailing(string <> separator, length)
  end

end
