# frozen_string_literal: true

require "asciidoctor-pdf"

module Prawn
  class Outline
    include Asciidoctor::NabeHelper
  end
end

module Asciidoctor
  module PDF
    class Converter
      def add_outline doc, num_levels = 2, toc_page_nums = [], num_front_matter_pages = 0, has_front_cover = false
        if ::String === num_levels
          if num_levels.include? ':'
            num_levels, expand_levels = num_levels.split ':', 2
            num_levels = num_levels.empty? ? (doc.attr 'toclevels', 2).to_i : num_levels.to_i
            expand_levels = expand_levels.to_i
          else
            num_levels = expand_levels = num_levels.to_i
          end
        else
          expand_levels = num_levels
        end
        front_matter_counter = RomanNumeral.new 0, :lower
        pagenum_labels = {}

        num_front_matter_pages.times do |n|
          pagenum_labels[n] = { P: (::PDF::Core::LiteralString.new front_matter_counter.next!.to_s) }
        end

        # add labels for each content page, which is required for reader's page navigator to work correctly
        (num_front_matter_pages..(page_count - 1)).each_with_index do |n, i|
          pagenum_labels[n] = { P: (::PDF::Core::LiteralString.new (i + 1).to_s) }
        end

        unless toc_page_nums.none? || (toc_title = doc.attr 'toc-title').nil_or_empty?
          toc_section = insert_toc_section doc, toc_title, toc_page_nums
        end

        outline.define do
          initial_pagenum = has_front_cover ? 2 : 1
          # FIXME: use sanitize: :plain_text once available
          keyname = "bookmark_include_title_page in theme-yaml"
          case three_state(document.theme.bookmark_include_title_page, keyname)
          when true
            doctitle = doc.header? ? doc.doctitle : (doc.attr 'untitled-label')
            doctitle ||= "title page"
            page title: (document.sanitize doctitle), destination: (document.dest_top has_front_cover ? 2 : 1)
          when false
            # nothing needs to happen
          else # nil
            if document.page_count >= initial_pagenum && (doctitle = doc.header? ? doc.doctitle : (doc.attr 'untitled-label'))
              page title: (document.sanitize doctitle), destination: (document.dest_top has_front_cover ? 2 : 1)
            end
          end
          # QUESTION is there any way to get add_outline_level to invoke in the context of the outline?
          document.add_outline_level self, doc.sections, num_levels, expand_levels
        end

        toc_section.parent.blocks.delete toc_section if toc_section

        catalog.data[:PageLabels] = state.store.ref Nums: pagenum_labels.flatten
        primary_page_mode, secondary_page_mode = PageModes[(doc.attr 'pdf-page-mode') || @theme.page_mode]
        catalog.data[:PageMode] = primary_page_mode
        catalog.data[:NonFullScreenPageMode] = secondary_page_mode if secondary_page_mode
        nil
      end
    end
  end
end
