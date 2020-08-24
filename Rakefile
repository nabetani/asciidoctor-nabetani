require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc 'Create Sample PDF'
task :pdf_funcs do
  cmd = %W[
    asciidoctor-pdf
    -r asciidoctor-pdf-cjk-kai_gen_gothic
    -r asciidoctor/nabetani/prawn-linewrap-ja
    -r asciidoctor/nabetani/abstractblock-xreftext
    -r asciidoctor/nabetani/pdf-custom-property
    -r asciidoctor/nabetani/horz-dlist
    -r asciidoctor/nabetani/pdf-outline
    sample/funcs/index.adoc
    -o sample/funcs.pdf
  ]
  sh cmd.join(' ')
end

desc 'Create Small Page PDF'
task :pdf_small do
  cmd = %W[
    asciidoctor-pdf
    -r asciidoctor-pdf-cjk-kai_gen_gothic
    -r asciidoctor/nabetani/prawn-linewrap-ja
    -r asciidoctor/nabetani/abstractblock-xreftext
    -r asciidoctor/nabetani/pdf-custom-property
    -r asciidoctor/nabetani/horz-dlist
    -r asciidoctor/nabetani/pdf-outline
    sample/small/index.adoc
    -o sample/small.pdf
  ]
  sh cmd.join(' ')
end

desc 'Create Sample PDF Without This Library'
task :pdf_funcs_org do
  cmd = %W[
    asciidoctor-pdf
    -r asciidoctor-pdf-cjk-kai_gen_gothic
    sample/funcs/index.adoc
    -o sample/funcs_org.pdf
  ]
  sh cmd.join(' ')
end

desc 'Create Small Page PDF Without This Library'
task :pdf_small_org do
  cmd = %W[
    asciidoctor-pdf
    -r asciidoctor-pdf-cjk-kai_gen_gothic
    sample/small/index.adoc
    -o sample/small_org.pdf
  ]
  sh cmd.join(' ')
end

task default: :spec
task funcs: [:pdf_funcs, :pdf_funcs_org]
task smalls: [:pdf_small, :pdf_small_org]
