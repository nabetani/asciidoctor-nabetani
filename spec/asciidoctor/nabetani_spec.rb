RSpec.describe Asciidoctor::Nabetani do
  it "has a version number" do
    expect(Asciidoctor::Nabetani::VERSION).not_to be nil
  end

  %w(
    prawn-linewrap-ja
    abstractblock-xreftext
    pdf-custom-property
    horz-dlist
    pdf-outline
  ).each do |lib_fn|
    it "can run and create pdf with #{lib_fn}" do
      here = File.split(__FILE__)[0]
      pdf_name = File.join( here, "spec_result.pdf" )
      FileUtils.rm_f( pdf_name )
      sample_dir = File.join( here, "../../" )
      src_adoc = "sample/src/index.adoc"
      Dir.chdir( sample_dir ) do
        `bundle exec asciidoctor-pdf -r asciidoctor/nabetani/#{lib_fn} -r asciidoctor-pdf-cjk-kai_gen_gothic "#{src_adoc}" -o #{pdf_name}`
        expect(File.exist?(pdf_name)).to be true
      end
    end
  end
end
