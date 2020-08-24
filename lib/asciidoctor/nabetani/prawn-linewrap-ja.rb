# Prawn の改行制御を変更するライブラリ。
# require すると、Prawn::Text::Formatted モジュールの LineWrap クラスを書き換える。
# 変更内容は
# * disable_wrap_by_char を常に true にする
# * 漢字やひらがなが続く文字列の途中での改行を許可する
# 辺り。
# * 行頭禁則・行末禁則の文字については asciidoctor-pdf-linewrap-ja を参考にした。
#
# known issue #1
#    メソッド tokenize で、文字コードを見るべきだが、見ていない。
#    utf-8 以外の入力があると不具合に見舞われると考えているが、試していない。
#

require "prawn"


module Asciidoctor
  module PDF
    class Converter
      # TODO: document me, esp the first line formatting functionality
      def typeset_text string, line_metrics, opts = {}
        move_down line_metrics.padding_top
        opts = { leading: line_metrics.leading, final_gap: line_metrics.final_gap }.merge opts

        # あとでちゃんとやるので、ここで ZeroWidthSpace を挟む必要はない
        # string = string.gsub CjkLineBreakRx, ZeroWidthSpace if @cjk_line_breaks
        if (hanging_indent = (opts.delete :hanging_indent) || 0) > 0
          indent hanging_indent do
            text string, (opts.merge indent_paragraphs: -hanging_indent)
          end
        elsif (first_line_opts = opts.delete :first_line_options)
          # TODO: good candidate for Prawn enhancement!
          text_with_formatted_first_line string, first_line_opts, opts
        else
          text string, opts
        end
        move_down line_metrics.padding_bottom
      end
    end
  end
end

module Prawn
  module Text
    module Formatted
      class LineWrap
        alias_method :original_initialize_line, :initialize_line

        def initialize_line(options)
          original_initialize_line(options)
          @disable_wrap_by_char = true
        end

        def self.or_rgexp( chars )
          s = chars.chars.map{ |e| Regexp.escape(e) }.join
          /[#{s}]/
        end

        PROHIBIT_LINE_BREAK_BEFORE_CHARS =
          '‐〜゠–' + # ハイフン類（cl-03）※ 普通の半角マイナスはエスケープが必要なので別途で
          '·・：；' + # 中点類（cl-05）
          '！？‼⁇⁈⁉' + # 区切り約物（cl-04）※ 半角の ? ! はエスケープが必要なので別途で
          '･・：；' + # 中点類（cl-05）※ 半角の : ; はエスケープが必要なので別途で
          '。．｡' + # 句点類（cl-06）※ 半角ピリオドはエスケープが必要なので別途で
          '、，､' + # 読点類（cl-07）※ 半角コンマはエスケープが必要なので別途で
          'ヽヾゝゞ々〻' + # 繰返し記号（cl-09）
          'ーｰ' + # 長音記号（cl-10）
          'ぁぃぅぇぉァィゥェォっゃゅょゎゕゖッャュョヮヵヶㇰㇱㇲㇳㇴㇵㇶㇷㇸㇹㇺㇻㇼㇽㇾㇿ'.freeze # 小書きの仮名（cl-11）

        # 行頭禁則
        PROHIBIT_LINE_BREAK_BEFORE = 
          /.[\-\.\,\!\?\:\;\p{Terminal_Punctuation}\p{Close_Punctuation}\p{Final_Punctuation}#{PROHIBIT_LINE_BREAK_BEFORE_CHARS}]/.freeze

        PROHIBIT_LINE_BREAK_AFTER_CHARS = "¿¡⸘"

        # 行末禁則
        PROHIBIT_LINE_BREAK_AFTER =
          /[\p{Initial_Punctuation}\p{Open_Punctuation}#{PROHIBIT_LINE_BREAK_AFTER_CHARS}]./.freeze

        # 各種ダッシュ。種類が異なってもよい。
        DASH_PATTERN = /[\u{2012}\u{2013}\u{2014}\u{2015}\u{2E3A}\u{2E3B}]{2}/

        # 同一種類のリーダーの2個繰り返し
        LEADER_PATTERN = /\u{2026}\u{2026}|\u{2025}\u{2025}|\u{22EF}\u{22EF}/

        ATMARKS = "\u{0040}\u{FE6B}\u{FF20}"
        UNDERSCORES = "\u{005F}\u{0332}\u{FF3F}"

        # 英数字・キリル文字・ギリシャ文字・コンマ・ピリオド の繰り返し
        ALNUM_PATTERN = /[\p{Latin}\p{Greek}\p{Cyrillic}0-9０-９\.\,#{ATMARKS}#{UNDERSCORES}]{2}/

        EXTRA_SPLITTABLE_CHAR =
          'ーｰ' + # 音引き
          '〇∞∴♂♀＆＊☆★○●◎◇◆□■△▲▽▼※♪◯©®'+ # 色々
          "\u{2026}\u{2025}\u{22EF}" + # リーダー
          "\u{2012}\u{2013}\u{2014}\u{2015}\u{2E3A}\u{2E3B}" # 各種ダッシュ

        def split_pattern(s)
          case s
          when PROHIBIT_LINE_BREAK_BEFORE,
               PROHIBIT_LINE_BREAK_AFTER,
               DASH_PATTERN,
               LEADER_PATTERN,
               ALNUM_PATTERN
            false
          when /[\-\s\p{Space}\u{200B}\u{00ad}]/, # 空白(200b は、ゼロ幅空白。00ad は、soft-hyphen)
               /[\p{Hiragana}\p{Katakana}#{EXTRA_SPLITTABLE_CHAR}\p{Han}]/, # 日本語等
               /[\p{Initial_Punctuation}\p{Open_Punctuation}]/, # 開き括弧等
               /[\p{Terminal_Punctuation}\p{Close_Punctuation}\p{Final_Punctuation}]/ # 閉じ括弧等
            true
          else
            false
          end
        end

        def tokenize(fragment)
          if /ち/===fragment
            x=0
          end
          fragment.size.times.with_object(["".clone]) do |ix,s|
            cur = fragment[ix]
            if s.last.empty?
              s.last << cur
            elsif split_pattern(s.last[-1]+cur)
              s.push cur
            else
              s.last << cur
            end
          end
        end

        def end_of_the_line_reached(segment)
          if !@fragment_output.strip.empty? && !segment.strip.empty?
            @line_contains_more_than_one_word = true
          end

          update_line_status_based_on_last_output
          unless @line_contains_more_than_one_word
            wrap_by_char(segment)
          end
          @line_full = true
        end

        def text_ended_with_breakable( text )
          true
        end

        def get_last_token_of(text)
          if text
            tokenize(text).last
          else
            ""
          end
        end

        def update_line_status_based_on_last_output
          if 1<tokenize(@fragment_output).size
            @line_contains_more_than_one_word = true
          end
        end

        def remember_this_fragment_for_backward_looking_ops
          @previous_fragment = @fragment_output.dup
          pf = @previous_fragment
          @previous_fragment_ended_with_breakable = text_ended_with_breakable(pf)
          @previous_fragment_output_without_last_word = get_last_token_of pf
        end
      end
    end
  end
end
