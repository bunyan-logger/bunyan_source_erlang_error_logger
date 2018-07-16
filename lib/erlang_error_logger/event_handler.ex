defmodule Bunyan.Source.ErlangErrorLogger.EventHandler do

  @behaviour :gen_event

  alias Bunyan.Shared.{ Collector, Level, LogMsg }
  alias Bunyan.Source.ErlangErrorLogger.{ Report }

  def init({ args, _term_from_erlang_error_logger }) do
    { :ok, args }
  end

  def init(args) do
    { :ok, args }
  end


  def handle_event(msg, state) do
    { :ok, error_log(msg, state) }
  end

  # gl === group_leader



  # Generated when error_msg/1,2 or format is called.
  def error_log({ :error, gl, { pid, format, data}}, state) do
    log(:error, gl, pid, format, data, state.collector)

    # TODO: one day...
    # case ErrorParser.parse(format, data, pid) do
    # nil ->
    #   log(:error, gl, pid, format, data, state.collector)
    # { msg_text, data, pid } ->
    #   log_already_formatted(:error, gl, pid, msg_text, data, state.collector)
    # end
    { :ok, state }
  end

  # Generated when warning_msg/1,2 is called if warnings are set to be tagged as warnings.
  def error_log({ :warning_msg, gl, { pid, format, data }}, state) do
    log(:warn, gl, pid, format, data, state.collector)
    { :ok, state }
  end

  # Generated when info_msg/1,2 is called.
  def error_log({ :info_msg, gl, { pid, format, data }}, state) do
    log(:info, gl, pid, format, data, state.collector)
    { :ok, state }
  end

  # reports are lists of  [{Tag :: term(), Data :: term()} | term()] | string() | term()

  # Generated when error_report/1 or /2 is called.
  def error_log({ :error_report, _gl, { pid, type, report }}, state) do
    Report.report(:error, pid, type, report, state.collector)
    { :ok, state }
  end

  # Generated when warning_report/1 or /2 is called if warnings are set to be
  # tagged as warnings.
  def error_log({ :warning_report, _gl, { pid, type, report }}, state) do
    Report.report(:warn, pid, type, report, state.collector)
    { :ok, state }
  end

  #  Generated when info_report/1 or /2 is called.
  def error_log({ :info_report, _gl, { pid, type, report }}, state) do
    Report.report(:info, pid, type, report, state.collector)
    { :ok, state }
  end

  def error_log(event, state) do
    IO.inspect error_log: event
    { :ok, state }
  end

  def handle_call(arg, state) do
    IO.inspect handle_call: arg
    { :ok, nil, state }
  end

  def log_already_formatted(level, _gl, pid, msg_text, data, collector) do
    IO.inspect laf: msg_text
    do_log(level, pid, msg_text, data, collector)
  end

  def log(level, _gl, pid, format, data, collector) when is_list(data) do
    msg_text = :io_lib.format(format, data)
              |> List.flatten()
              |> List.to_string()
              |> String.trim_trailing()

    do_log(level, pid, msg_text, data, collector)
  end

  def log(level, _gl, pid, format, data, collector) do
    msg = """
    bad data for format in `:error_logger.#{level}_msg(. . .):
    * list expected for 2nd parameter
    * see below for actual format string and data passed
    """

    do_log(level, pid, msg, %{ format: format, data: data }, collector)
  end

  # general fall-back handler
  def do_log(level, pid, msg_text, extra, collector) do
    msg = %LogMsg{
      level:     Level.of(level),
      msg:       msg_text,
      extra:     extra,
      timestamp: :os.timestamp(),
      pid:       pid,
      node:      node(pid)
    }
    Collector.log(collector, msg)
  end

end
