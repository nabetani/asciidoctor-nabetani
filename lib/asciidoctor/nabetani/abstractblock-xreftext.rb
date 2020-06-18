module Asciidoctor
  class Section < AbstractBlock
    def xreftext xrefstyle = nil
      if (val = reftext) && !val.empty?
        val
      elsif xrefstyle
        if @numbered
          case xrefstyle
          when 'custom'
            fmt = @document.attributes["xrefcustomformat"]
            fmt.gsub( "[$SECT_NUMS$]", sectnum.gsub( /[\.\,]$/, "" ) ).gsub( "[$TITLE$]", title )
          when 'full'
            if (type = @sectname) == 'chapter' || type == 'appendix'
              quoted_title = sub_placeholder (sub_quotes '_%s_'), title
            else
              quoted_title = sub_placeholder (sub_quotes @document.compat_mode ? %q(``%s'') : '"`%s`"'), title
            end
            if (signifier = @document.attributes[%(#{type}-refsig)])
              %(#{signifier} #{sectnum '.', ','} #{quoted_title})
            else
              %(#{sectnum '.', ','} #{quoted_title})
            end
          when 'short'
            if (signifier = @document.attributes[%(#{@sectname}-refsig)])
              %(#{signifier} #{sectnum '.', ''})
            else
              sectnum '.', ''
            end
          else # 'basic'
            (type = @sectname) == 'chapter' || type == 'appendix' ? (sub_placeholder (sub_quotes '_%s_'), title) : title
          end
        else # apply basic styling
          (type = @sectname) == 'chapter' || type == 'appendix' ? (sub_placeholder (sub_quotes '_%s_'), title) : title
        end
      else
        title
      end
    end
  end
end
