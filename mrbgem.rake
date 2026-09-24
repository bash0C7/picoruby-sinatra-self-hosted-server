# picoruby-sinatra-self-hosted-server: picoruby-sinatra-coversが対象外にしている
# self-hosted server(`App.run!`)を、picobrickで成り立たせる。
#
# Sinatra 4.2.1の`run!`は`Rackup::Handler.pick(server)`でhandlerを引き(picobrickが
# picoruby-rackupへ登録する)、`warn`で起動を知らせ、`traps`が真なら`at_exit`と`trap`で
# 終了の後始末を仕掛け、`rescue Errno::EADDRINUSE`する。
#
# SecureRandomはここに置けない: Sinatraはsinatra-coversの読み込み中(class本体)に
# `SecureRandom.hex(64)`を呼ぶが、このgemはsinatra-coversに依存するので、その後に
# 初期化される。SecureRandomはpicoruby-securerandomで、sinatra-coversより先に用意する。
MRuby::Gem::Specification.new("picoruby-sinatra-self-hosted-server") do |spec|
  spec.license = "MIT"
  spec.author = "bash0C7"
  spec.summary = "Self-hosted Sinatra (App.run!) on picobrick for PicoRuby"
  spec.add_dependency "picoruby-sinatra-covers"
  # picoruby-sinatra-coversの直後・picobrick(→picoruby-socket→picoruby-machine→
  # picoruby-require)より前に来る必要がある。理由はpicoruby-loaderror-reset
  # 自身のmrbgem.rakeのコメントを参照
  spec.add_dependency "picoruby-loaderror-reset",
                      gemdir: File.join(dir, "sub", "picoruby-loaderror-reset")
  # run!がRackup::Handler.pickで引く登録簿(picobrick経由でも入るが、run!が直接使うので書く)。
  # admin-host.rbが単独のconf.gem登録を持たないので、名前解決(MRUBY_ROOT/mrbgems/配下)
  # は効かない。このrepo自身のmrbgems/にあるので、gemdirで明示する
  spec.add_dependency "picoruby-rackup", gemdir: File.join(dir, "..", "picoruby-rackup")
  # 既定のserver。handlerをpicoruby-rackupへ登録する。理由は上のpicoruby-rackupと同じ
  spec.add_dependency "picobrick", gemdir: File.join(dir, "..", "picobrick")

  # PicoRubyはmrubyのcore gemをpicoruby-mrubyの下に持つ(sinatra-coversのmrbgem.rakeと同じ解決)
  mruby_gems = File.join(MRUBY_ROOT, "mrbgems", "picoruby-mruby", "lib", "mruby", "mrbgems")
  spec.add_dependency "mruby-errno", gemdir: File.join(mruby_gems, "mruby-errno")  # Errno::EADDRINUSE
  spec.add_dependency "mruby-io", gemdir: File.join(mruby_gems, "mruby-io")        # Kernel#warnの$stderr
end
