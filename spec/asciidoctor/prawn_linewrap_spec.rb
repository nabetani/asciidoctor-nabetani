require "asciidoctor/nabetani/prawn-linewrap-ja"
require "prawn"

RSpec.describe Asciidoctor::Nabetani do
  it "can create PDF" do
    here = File.split(__FILE__)[0]
    pdf_name = File.join(here, "spec_result.pdf" )
    FileUtils.rm_f(pdf_name)

    Prawn::Document.generate(pdf_name, page_size:'A7') do |pdf|
      letters = ([*?a..?z]*5).shuffle
      s = letters.map{ |e| "(#{e} #{e})" }.join
      pdf.text s
    end
  end
end
