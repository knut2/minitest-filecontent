#encoding: utf-8
=begin rdoc
=Gem MiniTest-Filecontent

Imagine you have a method and the result is a long text.

You can compare the result via assert_equal, but in case of
an error you must find the difference in the long text.

Wouldn't it be nice, you can store your expected result in a file and
in case of differences you get the real result in another file?
Now you can take your favorite file difference tool and can compare
the expected and the real result.

Here it is: MiniTest::Test#assert_equal_filecontent

=end

gem 'minitest', '>= 4.0.0'
require 'minitest/autorun'

require 'fileutils'
require 'date'  #needed for Ruby 1.9 (class Date no standard?)


#
module MiniTest
  module Filecontent
    VERSION = '0.1.1'
  end
  
=begin rdoc
Extend the class TestCase with additional methods/assertions:

* MiniTest::Test#assert_equal_filecontent
=end  
  class Test
    #Default path in case of an error.
    FOLDER_FOR_FAILURE = "failure_#{Date.today}"
    #Default path in case of an error. Overwrites FOLDER_FOR_FAILURE.
    #With 'false' no file is written
    attr_writer :folder_for_failure
=begin rdoc
Takes the content of the file 'filename' and compares it with 'actual' like in assert_equal.
If 'filename' doesn't exist, the failure 
 Reference file <#{filename}> missing
is returned.

'folder_for_failure' will contain all results with differences.

Example of the usage:
    assert_equal_filecontent( "expected/test_section.html", 
                              text.to_doc(:html), 
                              'short description of test'
                            )

What will happen:
1. text.to_doc(:html) is the test. It creates some HTML-Text
2. "expected/test_section.html" is read and compared to text.to_doc(:html)
   1. If the file is missing -> error
   2. If it is the same -> fine 
   3. If there are differences:
3. A message is given (like in assert_equal)
4. A folder "failure_#{Date.today}" is created if not already exist (See FOLDER_FOR_FAILURE )
5. The file 'test_section.html' with the result is created in FOLDER_FOR_FAILURE
6. You can use a compare tool to compare the expected result and the real result.

If you don't want a failure file (step 4 and 5), you may suppress it with:
  def text_no_failure file
    self.folder_for_failure = false  #inactivate error/reference file creation.
    #...
  end

==Recommendation to build up your test.
1. Define your tests with your assertions.
2. Run the test 
3. You will get errors 'Reference file <xx/not_available.txt> missing'
  and a directory 'failure_<date>
4. Rename the folder 'failure' to 'expected'
5. Check, if the content of the folder is the wanted result.
6. Rerun again, you have no failure (hopefully ;-) )

If you already have the result, you may start like this:
1. Create a folder: 'expected'
2. Define your assertion with non-existing filename in the 'expected'-folder.
3. Copy the expected results to the 'expected'-folder.
4. Run the test
5. In case of errors:
Compare the content of the 'expected'-folder with the failure-folder.
Adapt your code or your expected result.
6. Rerun again, until you get the expected results

==filename
The filename may contains some parameters in <x>. 
Details see MiniTest::Test#build_filename      

=end
    def assert_equal_filecontent( filename, actual, message = nil )
      
      filename = build_filename(filename)
      #Set encoding for the file
      encoding = actual.encoding if actual.respond_to?(:encoding)
      encoding ||= 'Binary' 
      
      full_message = []
      full_message << message if message
      
      expected = nil
      if File.exist?(filename)
        File.open(filename, 'r', :external_encoding => encoding ){|file| expected = file.read }
        #This message is only used in case of a difference
        full_message << "Result differs to file content #{filename}" 
      else
        full_message << "Reference file <#{filename}> is missing"
      end
      
      #Write the real result to a file if a failure folder is given.
      if @folder_for_failure != false and expected  != actual
        folder_for_failure = @folder_for_failure || FOLDER_FOR_FAILURE 
        FileUtils.makedirs(folder_for_failure) unless File.directory?(folder_for_failure)
        File.open( "#{folder_for_failure}/#{File.basename(filename)}", 'w', :external_encoding => encoding){|f|
          f << actual
        }
        full_message << "\t-> Build <#{folder_for_failure}/#{File.basename(filename)}>"
      end
      

      assert( expected == actual, full_message.join("\n") )

    end #assert_equal_filecontent( filename, actual, message = nil )

=begin rdoc
Make filename conversion.

The filename may contains some parameters in <x>. _x_ may be:
* c - test class name
* m - methodname from caller[level]
* cm - test class name - methodname

Parameter 'level' is needed to get the method.

Example:

  class MyTest < Test::Unit::TestCase
    def test_xx
      assert_equal_filecontent( "<m>.txt", mycode )
    end
  end 

The caller stack will be
  ___lib/more_unit_test/assert_equal_filecontent.rb:112:in `assert_equal_filecontent'
  quicktest.rb:13:in `test_xx'
  ___test-unit-2.4.0/lib/test/unit/testcase.rb:531:in `run_test'

The result with default level 1 is 'test_xx' - the method from your test.

=end
    def  build_filename(filename, level = 1)
      method = caller[level].match(/^(.+?):(\d+)(?::in `(.*)')?/)[3]  #methodname
      filename.gsub(/<.*?>/){ |hit|
        case hit
          when '<c>'; self.class.name
          when '<m>'; method
          when '<cm>'; "#{self.class}-#{method}" #methodname
          else; raise ArgumentError, "Undefined option #{hit} in filename #{filename}"
        end
      }.sub(/block (\(\d+ levels\) )?in /,'')
    end  #
  end  #class Test
end #Minitest

__END__

