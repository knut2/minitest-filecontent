#encoding: utf-8
=begin
Create gem minitest-filecontent
=end
$:.unshift('c:/usr/script/knut/knut-testtask/lib')
$:.unshift('c:/usr/script/knut/knut-gempackager/lib')
require 'knut-gempackager'  

require '../knut_pw.rb'
$:.unshift('lib')
require 'minitest/filecontent'
$minitest_filecontent_version = "0.1.0"

#http://docs.rubygems.org/read/chapter/20
gem_minitest_filecontent = Knut::Gem_packer.new('minitest-filecontent', $minitest_filecontent_version){ |gemdef, s|
  s.name = "minitest-filecontent"
  s.version =  $minitest_filecontent_version
  s.author = "Knut Lickert"
  s.email = "knut@lickert.net"
  #~ s.homepage = "http://ruby.lickert.net/minitest-filecontent"
  #~ s.homepage = "http://gems.rubypla.net/minitest-filecontent"
  #~ s.rubyforge_project = 'minitest-filecontent'
  s.platform = Gem::Platform::RUBY
  #~ s.required_ruby_version = '>= 1.9' #uses encoding...
  s.summary = "Support unit tests with expectations in files"
  s.description = <<-DESCR
Support unit tests with expectations in files
DESCR
  s.require_path = "lib"
  s.files = %w{
    readme.rdoc
    lib/minitest/filecontent.rb
    examples/example_minitest_filecontent.rb
  }
  s.test_files    = %w{
    unittest/test_minitest_filecontent.rb
  }
  #~ s.test_files   << Dir['unittest/expected/*']
  s.test_files.flatten!

  #~ s.bindir = "bin"
  #~ s.executables << 'minitest-filecontent.rb'

  s.rdoc_options << '--main' << 'readme.rdoc'
  s.extra_rdoc_files = %w{
    readme.rdoc
  }
  
  #~ s.add_dependency('') 
  #~ s.add_dependency('log4r')
  
  #~ s.add_development_dependency()
  #~ s.requirements << ''

  #~ gemdef.public = true
  #~ gemdef.add_ftp_connection('ftp.rubypla.net', Knut::FTP_RUBYPLANET_USER, Knut::FTP_RUBYPLANET_PW, "/Ruby/gemdocs/minitest-filecontent/#{$minitest_filecontent_version}")

  gemdef.define_test( 'unittest', FileList['test*.rb'])
  gemdef.versions << MiniTest::Filecontent::VERSION

}

#generate rdoc
task :rdoc_local do
  FileUtils.rm_r('doc') if File.exist?('doc')
  cmd = ["rdoc -f hanna"]
  cmd << gem_minitest_filecontent.spec.lib_files
  cmd << gem_minitest_filecontent.spec.extra_rdoc_files
  cmd << gem_minitest_filecontent.spec.rdoc_options
  `#{cmd.join(' ')}`
end
#~ desc "Gem minitest-filecontent"
task :default => :check
task :default => :test
task :default => :gem
#~ task :default => :install
#~ task :default => :rdoc_local
#~ task :default => :links
#~ task :default => :ftp_rdoc
#~ task :default => :push


if $0 == __FILE__
  app = Rake.application
  app[:default].invoke
end
__END__
