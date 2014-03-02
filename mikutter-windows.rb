# -*- coding: utf-8 -*-

require 'rbconfig'
require 'rubygems'
require 'Win32API'


class Hash
  alias :inspect_org :inspect

  # 魔の141行目問題を回避するよ。
  def inspect()
    result = self.inject({}) { |result, (key, item)|
      if item.is_a?(String)
        result[key] = item.encode(Encoding.default_external)
      else
        result[key] = item
      end

      result
    }

    result.inspect_org
  end
end


class File
  alias :flock_org :flock

  # flockがロックかかってないのに戻ってこなくなるので、そんなメソッド無かったことにする。
  def flock(ope)
    return 0
  end
end


module Gtk
  class << self
    alias :openurl_org :openurl

    # イメージウインドウをクリックしたときにブラウザが開かないバグへの対応
    def openurl(url)
      if url.frozen?
        openurl_org(url.melt)
      else
        openurl_org(url)
      end
    end
  end
end


Plugin.create(:windows) do
  on_boot { |service|
    defactivity("windows", "Windowsプラグイン")

    if !UserConfig[:windows_initialized_001]
      UserConfig[:activity_show_timeline] = UserConfig[:activity_show_timeline] + ["windows"]
      UserConfig[:sound_server] = :win32

      UserConfig[:windows_initialized_001] = true
    end

    delay = 10

    [
      "フォントはArial Unicode MSを使うと文字化けが少ないです",
      "設定の「通知」でmikutter/core/skin/data/sounds/のwavファイルを指定すると、mikutterがかわいくしゃべり始めます",
      Gem::Specification.find_by_path("gtk2").full_gem_path + '/vendor/local/lib/gtk-2.0/2.10.0/immodules/immodules.cacheを書き換えてインライン入力を実現しよう',
      "このお助けメッセージを非表示にするには、設定の「アクティビティ」で「Windowsプラグイン」のタイムライン表示をOFFにしよう。",
    ].each { |msg|

      Reserver.new(delay) {
        activity(:windows, msg)
      }

      delay += 10
    }
  }

  # サウンドを鳴らします
  defsound :win32, "Windows" do |filename|
    playsound = Win32API.new('winmm', 'PlaySound', 'ppl', 'i')
    playsound.call(filename, nil, 0)
  end
end