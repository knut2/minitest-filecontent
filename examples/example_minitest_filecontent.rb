#encoding: utf-8
=begin rdoc
Example for usage of gem minitest-filecontent
=end
$:.unshift('../lib')
require 'minitest/filecontent'

#Some content to be tested.
DUMMYTEXT = <<dummytext
Some text to be tested.
More text.
dummytext

puts "===================="
puts "=Remark: This example works correct, if 2 of the 3 assertions fail"
puts "=After the execution, there should be a directory failure_<isodate> with real results"
puts "===================="

class TestExample < MiniTest::Test
  def test_missing_reference_file
    assert_equal_filecontent('not_existing_filename.txt', DUMMYTEXT, 'My test with a missing reference file works correct, if this error is reported')
  end
  def test_file
    filename = '%s.txt' % __method__
    File.open(filename, 'w'){|f| f << DUMMYTEXT }
    assert_equal_filecontent(filename, DUMMYTEXT)
  end
  def test_file_difference
    filename = '%s.txt' % __method__
    File.open(filename, 'w'){|f| 
      f << DUMMYTEXT
      f << "and some other text"
    }
    assert_equal_filecontent(filename, DUMMYTEXT, 'My test with a modified content works correct, if this error is reported')
  end
end

