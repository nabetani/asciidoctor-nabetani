require "asciidoctor/nabetani/version"

module Asciidoctor
  module Nabetani
    class Error < StandardError; end
    # Your code goes here...
  end
end

require "asciidoctor-pdf"
require 'asciidoctor/nabetani/prawn-linewrap-ja'
require 'asciidoctor/nabetani/abstractblock-xreftext'
require 'asciidoctor/nabetani/pdf-custom-property'
require 'asciidoctor/nabetani/horz-dlist'
require 'asciidoctor/nabetani/pdf-outline'
