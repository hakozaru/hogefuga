require 'pry'

class Hoge
  def hoge
    p "Hoge#hoge"
  end
end

module ABC
  def hoge
    p "ABC#hoge"
  end
end

klass = Class.new(Hoge) do
  prepend ABC
end

# a = klass.new
# => #<#<Class:0x00007fba4a13b8f0>:0x00007fba29855e18>
# irb(main):003:0> a.hoge
# "ABC#hoge"
# => "ABC#hoge"

class ZZZ
  const_set(:QQQ, Class.new(Hoge) {
    prepend ABC
  })
end

# ZZZ.ancestors
# => [ZZZ, Object, Kernel, BasicObject]

# ZZZ::QQQ.ancestors
# => [ABC, ZZZ::QQQ, Hoge, Object, Kernel, BasicObject]

# a = ZZZ.new
# => #<ZZZ:0x00007fdaa596d2c8>
# irb(main):006:0> a.hoge
# Traceback (most recent call last):
#         3: from hoge.rb:23:in `<main>'
#         2: from <internal:prelude>:20:in `irb'
#         1: from /Users/hakozaru/Desktop/hoge.rb:6:in `<main>'
# NoMethodError (undefined method `hoge' for #<ZZZ:0x00007fdaa596d2c8>)

# a = ZZZ::QQQ.new
# => #<ZZZ::QQQ:0x00007fdaa0059b28>
# irb(main):008:0> a.hoge
# "ABC#hoge"


# ====================================================================

class YYY
end

module III
  using Module.new {
    refine ::YYY do
      def hoge
        p "III refine hoge"
      end

      class << ::YYY
        def hoge
          p "III refine hoge class method"
        end
      end
    end
  }

  def aaa
    # ::YYY.hoge => "III refine hoge class method"
    # ::YYY.new.hoge => "III refine hoge"
  end
end

class XXX < YYY
  extend III
end

# XXX.hoge => "III refine hoge class method"
# YYY.hoge => "III refine hoge class method"

# XXX.new.hoge => NoMethodError (undefined method `hoge')
# YYY.new.hoge => NoMethodError (undefined method `hoge')

# クラスメソッドの拡張は外からでもアクセスOKだけど、インスタンスメソッドはusingしたmoduleのスコープ内でしか有効にならない

# ==============================================================

module AAA
  def hoge
    p "AAA#hoge"
  end
end

module AAA
  def fuga
    p "AAA#fuga"
  end
end

class AAATST
  include AAA
end

# AAATST.new.hoge => OK
# AAATST.new.fuga => OK
# ClassもModuleもClassのインスタンスなので、オープンクラス的なことができる

# ================================

module Hakozaru
  # fuga.rbの中身は↓
  # module Hakozaru
  #   module Box
  #     def box
  #       p 'box'
  #     end
  #   end
  # end
  autoload :Box, './fuga'
end

# Hakozaru::Box を参照可能
# Hakozaru::Box.instance_methods => [:box]

# =============================================

module Hako1
  module_eval <<-RUBY, __FILE__, __LINE__
    def self.hoge
      p 'Hako1#hoge'
      raise
    end
  RUBY
end

module Hakozaru2
  def self.hoge
    fuga 123, <<-RUBY, "arg3"
      ヒアドキュメントの内容
    RUBY
  end

  def self.fuga(arg1, arg2, arg3)
    p arg1
    p arg2
    p arg3
  end
end

# ======================================================

class Hakozaru1
  def self.hoge
    p "first hoge"
  end

  def self.hoge
    p "second hoge"
  end unless singleton_methods.include?(:hoge)
end

binding.pry
