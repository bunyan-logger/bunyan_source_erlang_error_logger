defmodule Bunyan.Source.ErlangErrorLogger.ErrorParser do

  alias Bunyan.Source.ErlangErrorLogger.Util.Columns

  @moduledoc """
  Here be dragons.

  We attempt to analyze an error error_logger event by looking for stanzas in
  the format string. For example, if we see

      ** When Server state == ~tp

  and it's the 3rd occurrence of ~tp, we can assume that the third element in
  the data passed to the format is the server state.

  As a safety net, when we aren't sure of a parse, we bail and return `nil`,
  and the standard Erlang error format is used.
  """

  def parse(format, data, pid) when is_list(format) do
    parse(List.to_string(format), data, pid)
  end

  def parse(format, data, pid) when is_binary(format) do
    format
    |> parse_stanza(data, _result = %{})
    |> make_more_readable(data, pid)
  end

  def parse_stanza("** Generic server ~tp terminating \n" <> rest, [ server_name | data ], result) do
    parse_stanza(rest, data, Map.put(result, :gen_server_terminating, server_name))
  end

  def parse_stanza("** Last message in was ~tp~n" <> rest, [ msg |  data ], result) do
    parse_stanza(rest, data, Map.put(result, :last_msg, msg))
  end

  def parse_stanza("** When Server state == ~tp~n" <> rest, [ state |  data ], result) do
    parse_stanza(rest, data, Map.put(result, :server_state, state))
  end

  def parse_stanza("** Reason for termination == ~n** ~tp~n" <> rest, [ { reason, stack } |  data ], result) do
    parse_stanza(rest, data, Map.put(result, :reason, reason) |> Map.put(:reason_stack, stack))
  end

  def parse_stanza("** Client ~p stacktrace~n** ~tp~n" <> rest, [ client, stack |  data ], result) do
    parse_stanza(rest, data, Map.put(result, :client_stack, { client, stack }))
  end

  def parse_stanza("Error in process ~p on node ~p with exit value:~n~p~n" <> rest,
                   [ process, node, error | data ],
                   result) do
    parse_stanza(rest, data, Map.put(result, :error_in_process, { process, node, error }))
  end


  def parse_stanza("", [], result) do
    result
  end


  def parse_stanza("", data, result) do
    IO.inspect trailing_data: data
    :erlang.halt
  end


  def parse_stanza(other, data, result) do
    IO.puts "Don't recognize stanza #{inspect other}"
    IO.inspect so_far: result
    IO.inspect data: data, pretty: true
    nil
  end

  #--------------------------------------------------------------------------------------------+
  #  And here we do formatting, butting the stanzas into order and prettying them up a little  |
  #--------------------------------------------------------------------------------------------+

  def make_more_readable(nil, _data, _pid) do
    nil
  end

  def make_more_readable(stanzas, data, pid) do
    try do
    IO.inspect mmr: { stanzas, pid }
    { contents, new_pid } = [
      :client_stack,
      :server_state,
      :reason_stack,
      :reason,
      :last_msg,
      :gen_server_terminating,
      :error_in_process
    ]
    |> Enum.reduce({_result, _pid}  = { [], pid }, fn key, { result, new_pid } ->
      IO.inspect key
         case stanzas[key] do
           nil    -> IO.inspect(result)
           stanza -> case IO.inspect(one_readable_stanza(key, stanza)) do
                     { :set_pid, override, content } ->
                      IO.inspect set_pid: override
                        { [ content | result ], override }
                     content ->
                      IO.inspect no_set: content
                      { [ content | result ], new_pid }
                     end
         end
       end)

      |> IO.inspect(label: "reduce")

    text_as_iolist = Columns.align(contents, align: :right, line_end: "\n\n")
    IO.inspect { IO.iodata_to_binary(text_as_iolist), data, new_pid }, label: "final"
      rescue
        e in _ ->
          IO.inspect e
        end
  end

  def one_readable_stanza(:gen_server_terminating, server) do
    { "GenServer terminating",  to_string(server) }
  end

  def one_readable_stanza(:last_msg, msg) do
    { "it was handling", inspect msg }
  end

  def one_readable_stanza(:reason, code) do
    format_reason(code)
  end

  def one_readable_stanza(:reason_stack, stack) do
    { "", { :__double_indent__, format_stacktrace(stack) }}
  end

  def one_readable_stanza(:client_stack, { pid, stack }) do
    case format_stacktrace(stack) do
      [] ->
        []
      stacktrace ->
        { "Calling process #{format_pid(pid)}", { :__double_indent__, stacktrace }}
    end
  end

  def one_readable_stanza(:server_state, state) do
    { "Server state", inspect(state, pretty: true) }
  end

  def one_readable_stanza(:error_in_process, { pid, node, error }) do
    { :set_pid, pid, { "Error in process #{format_pid(pid)} on #{node}", error_detail(error) }}
  end

  def one_readable_stanza(nil, _) do
    []
  end

  def one_readable_stanza(unknown, _) do
    IO.inspect unknown_stanza: unknown
    to_string(unknown)
  end

  def format_reason(error) do
    { "Error message", error_detail(error) }
  end

  def error_detail(:badarg),
  do: "Argument is the wrong type or is badly formed"

  def error_detail(:badarith),
  do: "Bad argument in an arithmetic expression"

  def error_detail({ :badmatch, match }),
  do: "The value «#{inspect match}» could not be matched by `=`"

  def error_detail(:function_clause),
  do: "No matching function clause is found when evaluating a function call"

  def error_detail({ :case_clause, value }),
  do: "The value «#{inspect value}» did not match any branch of a case expression. "

  def error_detail(:if_clause),
  do: "No true branch found for `if` expression"

  def error_detail({ :try_clause, match }),
  do: "Couldn't match «#{inspect match}» in a `try` expression"

  def error_detail(:undef),
  do: "A matching function cannot be found"

  def error_detail({ :undef, [{m, f, a, _}]}),
  do: "Function #{format_mfa(m, f, a)} not found"

  def error_detail({ :badfun, f }),
  do: "Error with function «#{inspect f}».\n(perhaps you're using a variable in a context that needs a function?)"

  def error_detail({ :badarity, f }),
  do: "Function «#{inspect f}» is called with the wrong number of arguments"

  def error_detail(:timeout_value),
  do: "Timeout value in a `receive` is not an integer"

  def error_detail(:noproc),
  do: "Tried to link to a nonexistent process"

  def error_detail({ :nocatch, value }),
  do: "`throw(#{inspect value}) called, but no matching `catch`"

  def error_detail(:system_limit),
  do: "A system limit has been exceeded"

  def error_detail(other),
  do: inspect(other, pretty: true)

  def format_stacktrace(stack) do
    stack
    |> Enum.reduce([], &one_stack_frame/2)
    |> Enum.reverse()
    |> Columns.align()
  end

  @dont_care_modules [
    :gen,
    :gen_server,
    :elixir,
    :proc_lib,
    IEx.Evaluator,
  ]

  defp one_stack_frame({ module, _function, _args, _location }, result) when module in @dont_care_modules do
    result
  end

  defp one_stack_frame({ module, function, args, location }, result) do
    [
      { format_location(location), format_mfa(module, function, args) }
    |
      result
    ]
  end

  defp one_stack_frame(other, result) do
    IO.inspect other: other
    result
  end

  defp format_mfa(m, f, a) when is_integer(a) do
    "#{inspect m}.#{f}/#{a}"
  end

  defp format_mfa(m, f, a) when is_list(a) do
    args = Enum.map(a, &inspect/1) |> Enum.join(", ")
    "#{inspect m}.#{f}(#{args})"
  end

  defp format_pid(pid) do
    if (node = node(pid)) != node() do
      "#{format_just_pid(pid)} on #{node}"
    else
      format_just_pid(pid)
    end
  end

  defp format_just_pid(pid) do
    inspect(pid) |> String.replace("PID", "")
  end

  defp format_location(location) do
    file_ref(location[:file], location[:line])
  end

  defp file_ref(nil, nil) do
    "[—]"
  end

  defp file_ref(file, line) do
    "[#{file}:#{line}]"
  end


end
