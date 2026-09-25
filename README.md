# picoruby-sinatra-self-hosted-server

Self-hosted Sinatra (`App.run!`) for
[PicoRuby](https://github.com/picoruby/picoruby), on top of
[picobrick](https://github.com/bash0C7/picobrick).

[`picoruby-sinatra-covers`](https://github.com/udzura/picoruby-sinatra-covers)
(Sinatra on PicoRuby) explicitly leaves the self-hosted server
(`App.run!`) out of scope. This gem fills that gap: Sinatra 4.2.1's
`run!` looks up a handler with `Rackup::Handler.pick(server)` (picobrick
registers itself there), announces startup with `warn`, and - if
`traps` is true - wires up `at_exit`/`trap` for shutdown and rescues
`Errno::EADDRINUSE`. This gem supplies those pieces and picks sane
PicoRuby-appropriate defaults.

## Installation

```ruby
conf.gem github: 'bash0C7/picoruby-sinatra-self-hosted-server', branch: 'main'
```

## Dependencies

- [`picoruby-sinatra-covers`](https://github.com/udzura/picoruby-sinatra-covers)
- [`picoruby-rackup`](https://github.com/bash0C7/picoruby-rackup) and
  [`picobrick`](https://github.com/bash0C7/picobrick) - **must be
  checked out as sibling directories of this gem** (this gem's own
  `mrbgem.rake` resolves them with `File.join(dir, "..", "picoruby-rackup")`
  / `File.join(dir, "..", "picobrick")`, so it never assumes anything
  about the consuming project's own directory layout)
- `mruby-errno` (`Errno::EADDRINUSE`), `mruby-io` (`Kernel#warn`'s `$stderr`)

Consumers must **not** also register `picoruby-socket`,
`picoruby-rackup`, or `picobrick` as independent top-level `conf.gem`
entries in their own build_config - PicoRuby's `mrbgem.rake` init order
is decided by `conf.gem` declaration order (via topological sort, which
never revisits an already-registered gem), so an independent entry for
one of these would take priority over this gem's own dependency chain
and break `picoruby-loaderror-reset`'s positioning silently (see below).

## Usage

```ruby
require 'sinatra/base'
require 'sinatra_covers'
require 'sinatra_self_hosted_server'

class App < Sinatra::Base
  get "/hello/:name" do
    "Hello, #{params[:name]}"
  end
end

App.run!
```

That's it - no app-side changes needed. This gem sets these `Sinatra::Base`
defaults (an app can still override them with its own `set`):

| Setting | Value | Why |
|---|---|---|
| `server` | `%w[picobrick]` | Sinatra's own default is `%w[webrick]`, which doesn't exist here |
| `traps` | `false` | PicoRuby's `Kernel` has neither `at_exit` nor `trap`; a fake `at_exit` isn't manufactured here |

It also defines `Kernel#warn` (writing to `$stderr`) if the VM doesn't
already have one, since `run!` uses it to announce startup
(`== Sinatra ... has taken the stage on <port> ... with backup from
Picobrick`).

## Bundled: picoruby-loaderror-reset

`picoruby-require` unconditionally (re)defines `LoadError <
StandardError`. `picoruby-sinatra-covers` defines its own `LoadError`
too (guarded by `unless Object.const_defined?(:LoadError)` since
[its PR #6](https://github.com/udzura/picoruby-sinatra-covers/pull/6),
with the correct `LoadError < ScriptError` ancestry) - but this build's
gem init order always runs `picoruby-sinatra-covers` before
`picoruby-require` (see `mrbgem.rake`'s dependency ordering below), so
`picoruby-require`'s unconditional redefinition still collides with
whatever `picoruby-sinatra-covers` already defined, superclass
mismatch or not. Guarding one side isn't enough when the other side
never checks. `sub/picoruby-loaderror-reset` is a tiny gem
(`Object.send(:remove_const, :LoadError) if
Object.const_defined?(:LoadError)`) that this gem depends on and
positions, via mrbgem dependency ordering, right after
`picoruby-sinatra-covers` and before `picoruby-require` - clearing
whatever `picoruby-sinatra-covers` defined so `picoruby-require`'s
redefinition lands clean. It depends on nothing but
`picoruby-sinatra-covers`, is not published on its own, and travels
with this gem.

## Testing

This gem doesn't carry an automated test suite: its own contribution
(`run!`'s handler pick, `warn`, `traps` defaults) is a thin layer over
`Sinatra::Base` and `App.run!`, with no deterministic input/output of
its own to assert on. Check it by actually running `App.run!` and
hitting it, in whatever app embeds this gem.

## License

MIT
