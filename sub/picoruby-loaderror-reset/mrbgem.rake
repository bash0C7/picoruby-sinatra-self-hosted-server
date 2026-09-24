# picoruby-loaderror-reset: upstreamのpicoruby-sinatra-coversとpicoruby-requireを
# forkせずに共存させるための1点だけのgem。どちらも`class LoadError < 何か; end`を
# 無条件で宣言するため、順序に関係なく2つ目の宣言でsuperclass mismatch(TypeError)になる
# (実機で確認済み。順序を入れ替えても症状は変わらない)。`raise`/`rescue`は実行時に
# 定数を遅延解決するので、間で一度remove_constしておけば、後から読む方の宣言が
# そのまま最終形になる。picoruby-sinatra-coversの直後・picoruby-socket
# (→picoruby-machine→picoruby-require)より前に来るよう、
# picoruby-sinatra-self-hosted-serverのmrbgem.rakeで依存の並びを固定する
# (このgem自身はpicobrick・picoruby-rackupに依存してはいけない。依存すると
# picoruby-socketのtsort順に引きずられて位置が崩れる)。
MRuby::Gem::Specification.new("picoruby-loaderror-reset") do |spec|
  spec.license = "MIT"
  spec.author = "bash0C7"
  spec.summary = "Clear LoadError before a later unconditional redeclaration, for PicoRuby"
  spec.add_dependency "picoruby-sinatra-covers"
end
