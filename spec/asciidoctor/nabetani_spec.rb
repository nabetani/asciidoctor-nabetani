RSpec.describe Asciidoctor::Nabetani do
  it "has a version number" do
    expect(Asciidoctor::Nabetani::VERSION).not_to be nil
  end

  it "can run and create pdf" do
    here = File.split(__FILE__)[0]
    pdf_name = File.join( here, "spec_result.pdf" )
    FileUtils.rm_f( pdf_name )
    sample_dir = File.join( here, "../../" )
    src_adoc = "sample/funcs/index.adoc"
    Dir.chdir( sample_dir ) do
      `bundle exec asciidoctor-pdf -r asciidoctor/nabetani "#{src_adoc}" -o #{pdf_name}`
      expect(File.exist?(pdf_name)).to be true
    end
  end
end
