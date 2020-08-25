require "asciidoctor-pdf"

module Asciidoctor
  module PDF
    class Converter
      alias_method :build_pdf_info_original, :build_pdf_info
      def build_pdf_info doc
        info = build_pdf_info_original(doc)
        keys = %w( Title Author Subject Keywords Producer Creator )
        keys.each do |key|
          val = doc.attr( ("pdf_"+key).downcase )
          next unless val
          info[ key.to_sym ] = val.to_s.as_pdf
        end
        info
      end
    end
  end
end


