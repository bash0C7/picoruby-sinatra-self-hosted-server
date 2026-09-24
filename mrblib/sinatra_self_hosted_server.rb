# `run!`がPicoRubyで動くための既定値。appの側で`set`すれば上書きできる。
#
# - server: picobrick(Sinatraの既定は%w[webrick])
# - traps: 偽。`run!`はtrapsが真だと`at_exit`と`trap(:INT/:TERM)`で終了の後始末を
#   仕掛けるが、PicoRubyのKernelにはどちらも無い(終了時にblockを走らせる口が無い)
Sinatra::Base.set :server, %w[picobrick]
Sinatra::Base.set :traps, false

# CRubyのKernel#warn。`run!`が起動の知らせ(`== Sinatra ... has taken the stage ...`)に使う。
# PicoRubyのKernelには無い
module Kernel
  unless Kernel.respond_to?(:warn, true)
    def warn(*messages, uplevel: nil, category: nil)
      messages.each { |message| $stderr.puts(message) }
      nil
    end
  end
end
