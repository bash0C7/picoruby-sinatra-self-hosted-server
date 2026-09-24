# ここで一度消しておくことで、次に読まれるgem(picoruby-requireなど)の
# `class LoadError < 何か; end`という無条件宣言がsuperclass mismatchにならずに
# 成功する。消してから再定義されるまでの間にLoadErrorへ触れるコードは無い
# (gem初期化の途中で`raise`/`rescue LoadError`は起きない)。
Object.send(:remove_const, :LoadError) if Object.const_defined?(:LoadError)
