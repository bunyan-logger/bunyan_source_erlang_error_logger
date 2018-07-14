defmodule Test.ErrorLogger.Util.Columns do
  use ExUnit.Case
  import  Bunyan.Source.ErlangErrorLogger.Util.Columns

  test "basic alignment" do
    result = align([{ "small", "one"}, { "and longer", "two" }])
    assert result == [["small:       ", "one", "\n"], ["and longer:  ", "two", "\n"]]
  end

  test "basic alignment, different order" do
    result = align([{ "and longer", "two" }, { "small", "one"}])
    assert result == [ ["and longer:  ", "two", "\n"], ["small:       ", "one", "\n"]]
  end

  test "custom separator" do
    result = align([{ "small", "one"}, { "and longer", "two" }], separator: "-->")
    assert result == [["small-->     ", "one", "\n"], ["and longer-->", "two", "\n"]]
  end

  test "right alignment" do
    result = align([{ "small", "one"}, { "and longer", "two" }], separator: "> ", align: :right)
    assert result == [["     small> ", "one", "\n"], ["and longer> ", "two", "\n"]]
  end

  test "with a long entry in first column" do
    result = align([
      { "small", "one"},
      { "very very long label that I wrote", "three" },
      { "and longer", "two" },
    ])
    assert result == [
      ["small:       ", "one", "\n"],
      ["very very long label that I wrote", ":  ", "\n", "             ", "three", "\n"],
      ["and longer:  ", "two", "\n"]
    ]
  end
end
