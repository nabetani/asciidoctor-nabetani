require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc 'Create Sample PDF'
task :pdf do
  cmd = %W[
    asciidoctor-pdf
    -r asciidoctor-pdf-cjk-kai_gen_gothic
    -r asciidoctor/nabetani/prawn-linewrap-ja
    sample/src/index.adoc
    -o sample/book.pdf
  ]
  sh cmd.join(' ')
end

task default: :spec
