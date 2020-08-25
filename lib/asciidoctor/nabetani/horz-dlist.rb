require "asciidoctor-pdf"
require_relative "nabehelper"

module Asciidoctor
  module PDF
    class Converter
      include NabeHelper
      def convert_paragraph node
        add_dest_for_block node if node.id
        prose_opts = { margin_bottom: 0, hyphenate: true }
        lead = (roles = node.roles).include? 'lead'
        if (align = resolve_alignment_from_role roles)
          prose_opts[:align] = align
        end

        if (text_indent = @theme.prose_text_indent || 0) > 0
          prose_opts[:indent_paragraphs] = text_indent
        end

        # TODO: check if we're within one line of the bottom of the page
        # and advance to the next page if so (similar to logic for section titles)
        layout_caption node.title if node.title?

        if lead
          theme_font :lead do
            layout_prose node.content, prose_opts
          end
        else
          layout_prose node.content, prose_opts
        end

        dlist = node&.parent&.parent&.parent

        if dlist&.style=="horizontal"
          m = get_node_attriute_float( dlist, "margin-bottom", nil )
          if m
            margin_bottom m
            return
          end
        end
        if (margin_inner_val = @theme.prose_margin_inner) &&
            (next_block = (siblings = node.parent.blocks)[(siblings.index node) + 1]) && next_block.context == :paragraph
          margin_bottom margin_inner_val
        else
          margin_bottom @theme.prose_margin_bottom
        end
      end

      def convert_dlist node
        add_dest_for_block node if node.id

        case (style = node.style)
        when 'unordered', 'ordered'
          if style == 'unordered'
            list_style = :ulist
            (markers = @list_bullets) << :disc
          else
            list_style = :olist
            (markers = @list_numerals) << 1
          end
          list = List.new node.parent, list_style
          stack_subject = node.has_role? 'stack'
          subject_stop = node.attr 'subject-stop', (stack_subject ? nil : ':'), false
          node.items.each do |subjects, dd|
            subject = [*subjects].first.text
            list_item_text = %(+++<strong>#{subject}#{(StopPunctRx.match? sanitize subject) ? '' : subject_stop}</strong>#{dd.text? ? "#{stack_subject ? '<br>' : ' '}#{dd.text}" : ''}+++)
            list_item = ListItem.new list, list_item_text
            dd.blocks.each {|it| list_item << it }
            list << list_item
          end
          convert_outline_list list
          markers.pop
        when 'horizontal'
          table_data = []
          term_padding = desc_padding = term_line_metrics = term_inline_format = term_kerning = nil
          max_term_width = 0
          theme_font :description_list_term do
            if (term_font_styles = font_styles).empty?
              term_inline_format = true
            else
              term_inline_format = [inherited: { styles: term_font_styles }]
            end
            margin_left = get_node_attriute_float(node, 'margin-left', 10)
            margin_bottom = get_node_attriute_float(node, 'margin-bottom', (@theme.prose_margin_bottom || 0) * 0.5 )
            term_line_metrics = calc_line_metrics @theme.description_list_term_line_height || @theme.base_line_height
            term_padding = [
              term_line_metrics.padding_top, # up
              10, # right
              margin_bottom + term_line_metrics.padding_bottom, # bottom
              margin_left # left
            ]
            desc_padding = [
              0, # up
              10, # right
              margin_bottom, # bottom
              10 # left
            ]
            term_kerning = default_kerning?
          end
          node.items.each do |terms, desc|
            term_text = terms.map(&:text).join ?\n
            if (term_width = width_of term_text, inline_format: term_inline_format, kerning: term_kerning) > max_term_width
              max_term_width = term_width
            end
            row_data = [{
              text_color: @font_color,
              kerning: term_kerning,
              content: term_text,
              inline_format: term_inline_format,
              padding: term_padding,
              leading: term_line_metrics.leading,
              # FIXME: prawn-table doesn't have support for final_gap option
              #final_gap: term_line_metrics.final_gap,
              valign: :top,
            }]
            desc_container = Block.new desc, :open
            desc_container << (Block.new desc_container, :paragraph, source: (desc.instance_variable_get :@text), subs: :default) if desc.text?
            desc.blocks.each {|b| desc_container << b } if desc.block?
            row_data << {
              content: (::Prawn::Table::Cell::AsciiDoc.new self, content: desc_container, text_color: @font_color, padding: desc_padding, valign: :top),
            }
            table_data << row_data
          end
          max_term_width += (term_padding[1] + term_padding[3])
          term_column_width = [max_term_width, bounds.width * 0.5].min
          table table_data, position: :left, cell_style: { border_width: 0 }, column_widths: [term_column_width] do
            @pdf.layout_table_caption node if node.title?
          end
          margin_bottom 0 # (@theme.prose_margin_bottom || 0) * 0.5
        when 'qanda'
          @list_numerals << '1'
          convert_outline_list node
          @list_numerals.pop
        else
          # TODO: check if we're within one line of the bottom of the page
          # and advance to the next page if so (similar to logic for section titles)
          layout_caption node.title, category: :description_list if node.title?

          term_line_height = @theme.description_list_term_line_height || @theme.base_line_height
          line_metrics = theme_font(:description_list_term) { calc_line_metrics term_line_height }
          node.items.each do |terms, desc|
            # NOTE: don't orphan the terms (keep together terms and at least one line of content)
            allocate_space_for_list_item line_metrics, (terms.size + 1), ((@theme.description_list_term_spacing || 0) + 0.05)
            theme_font :description_list_term do
              if (term_font_styles = font_styles).empty?
                term_font_styles = nil
              end
              terms.each do |term|
                # QUESTION should we pass down styles in other calls to layout_prose
                layout_prose term.text, margin_top: 0, margin_bottom: @theme.description_list_term_spacing, align: :left, line_height: term_line_height, normalize_line_height: true, styles: term_font_styles
              end
            end
            indent(@theme.description_list_description_indent || 0) do
              traverse_list_item desc, :dlist_desc, normalize_line_height: true
            end if desc
          end
        end
      end
    end
  end
end
