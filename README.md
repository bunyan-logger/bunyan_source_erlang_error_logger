# Bunyan.Source.ErlangErrorLogger

<!-- bunyan_header -->

## Summary

This is a source plugin for the [Bunyan
logger](https://github.com/bunyan-logger/bunyan) project.

It is responsible for receiving log messages and reports from the
standard Erlang error logger and injecting them into Bunyan.

By default, it will also capture OTP and SASL reports.

### Installation

~~~ elixir
{ :bunyan_source_erlang_error_logger, "~> 0.0.0" },
~~~

### Configuration

This plugin is configured as part of the sources section of the overall
Bunyan configuration.

For context, the main Bunyan config looks like this:

~~~ elixir
config :bunyan,
       [
        read_from: [
          { source, [ source-specific config ] },
          { source, [ source-specific config ] },
          . . .
        ],

        write_to: [
          { writer, [ writer-specific config ] },
          { writer, [ writer-specific config ] },
        ]
      ]
~~~

The configuration described here becomes an entry in the `read_from:`
section. It looks like this:

~~~ elixir
{
  Bunyan.Source.ErlangErrorLogger,
  [
    name:    «name»,
  ]
}
~~~

* `name:` gives an instance of the erlang error logger a name. In the
  (unusual) case where you run multiple erlang error loggers, the name
  is used to distinguish them.
