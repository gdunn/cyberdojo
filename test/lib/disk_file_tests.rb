require File.dirname(__FILE__) + '/../test_helper'
require 'DiskFile'

class DiskFileTests < ActionController::TestCase

  def setup
    id = 'ABCDE12345'
    @disk_file = DiskFile.new
    @folder = root_dir + @disk_file.separator + id
  end
  
  def teardown
    system("rm -rf #{@folder}")
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test "if_path_does_not_exist_exception_is_thrown_block_is_not_executed_and_result_is_nil" do
    block_run = false
    exception_throw = false
    begin
      result = @disk_file.lock('does_not_exist.txt') do |fd|
        block_run = true
      end
    rescue
      exception_thrown = true
    end

    assert exception_thrown
    assert !block_run
    assert_nil result
  end

  test "if_lock_is_obtained_block_is_executed_and_result_is_result_of_block" do
    block_run = false
    filename = 'exists.txt'
    @disk_file.write('.', filename, 'x=[1,2,3]')
    fd = File.open(filename, 'r')
    begin
      result = @disk_file.lock(filename) {|fd| block_run = true; 'Hello' }
      assert block_run, 'block_run'
      assert_equal 'Hello', result
    ensure
      File.delete(filename)
    end
  end
  
  test "outer_lock_is_blocking_so_inner_lock_blocks" do
    filename = 'exists.txt'
    @disk_file.write('.', filename, 'x=[1,2,3]')
    outer_run = false
    inner_run = false
    @disk_file.lock(filename) do
      outer_run = true
      
      inner_thread = Thread.new {
        @disk_file.lock(filename) do
          inner_run = true
        end
      }
      max_seconds = 2
      result = inner_thread.join(max_seconds);
      timed_out = (result == nil)
      if inner_thread != nil
        Thread.kill(inner_thread)
      end
    end
    assert outer_run
    assert !inner_run
    `rm #{filename}`
  end
  
  test "lock_can_be_acquired_on_an_existing_dir" do
    dir = 'new_dir'
    `mkdir #{dir}`
    begin
      run = false
      result = @disk_file.lock(dir) {|_| run = true }
      assert run
      assert result
    ensure
      `rmdir #{dir}`      
    end
  end
  
  test "holding_lock_on_parent_dir_does_not_prevent_acquisition_of_lock_on_child_dir" do
    parent = 'parent'
    child = parent + @disk_file.separator + 'child'
    `mkdir #{parent}`
    `mkdir #{child}`
    begin
      parent_run = false
      child_run = false
      @disk_file.lock(parent) do
        parent_run = true
        @disk_file.lock(child) do
          child_run = true
        end
      end
      assert parent_run
      assert child_run
    ensure
      `rmdir #{child}`
      `rmdir #{parent}`
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  test "save_file for non-string is saved as inspected object and folder is automatically created" do
    object = { :a => 1, :b => 2 }
    check_save_file('manifest.rb', object, "{:a=>1, :b=>2}\n", false)
  end
  
  test "save_file for string - folder is automatically created" do
    object = "hello world"
    check_save_file('manifest.rb', object, "hello world", false)
  end

  test "saving a file with a folder creates the subfolder and the file in it" do
    pathed_filename = 'f1/f2/wibble.txt'
    content = 'Hello world'
    @disk_file.write(@folder, pathed_filename, content)

    full_pathed_filename = @folder + File::SEPARATOR + pathed_filename    
    assert File.exists?(full_pathed_filename),
          "File.exists?(#{full_pathed_filename})"
    assert_equal content, IO.read(full_pathed_filename)          
  end

  test "save file for non executable file" do
    check_save_file('file.a', 'content', 'content', false)
  end
  
  test "save file for executable file" do
    check_save_file('file.sh', 'ls', 'ls', true)
  end
  
  test "save filename longer than but ends in makefile is not auto-tabbed" do
    content = '    abc'
    expected_content = content
    check_save_file('smakefile', content, expected_content, false)    
  end  
  
  test "save file for makefile converts all leading whitespace on a line to a single tab" do
    check_save_makefile("            abc", "\tabc")
    check_save_makefile("        abc", "\tabc")
    check_save_makefile("    abc", "\tabc")
    check_save_makefile("\tabc", "\tabc")
  end
  
  test "save file for Makefile converts all leading whitespace on a line to a single tab" do
    check_save_file('Makefile', "            abc", "\tabc", false)
    check_save_file('Makefile', "        abc", "\tabc", false)
    check_save_file('Makefile', "    abc", "\tabc", false)
    check_save_file('Makefile', "\tabc", "\tabc", false)
  end
  
  test "save file for makefile converts all leading whitespace to single tab for all lines in any line format" do
    check_save_makefile("123\n456", "123\n456")
    check_save_makefile("123\r\n456", "123\n456")
    
    check_save_makefile("    123\n456", "\t123\n456")
    check_save_makefile("    123\r\n456", "\t123\n456")
    
    check_save_makefile("123\n    456", "123\n\t456")
    check_save_makefile("123\r\n    456", "123\n\t456")
    
    check_save_makefile("    123\n   456", "\t123\n\t456")
    check_save_makefile("    123\r\n   456", "\t123\n\t456")
    
    check_save_makefile("    123\n456\n   789", "\t123\n456\n\t789")    
    check_save_makefile("    123\r\n456\n   789", "\t123\n456\n\t789")    
    check_save_makefile("    123\n456\r\n   789", "\t123\n456\n\t789")    
    check_save_makefile("    123\r\n456\r\n   789", "\t123\n456\n\t789")    
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  def check_save_makefile(content, expected_content)    
    check_save_file('makefile', content, expected_content, false)
  end
      
  def check_save_file(filename, content, expected_content, executable)
    @disk_file.write(@folder, filename, content)
    pathed_filename = @folder + File::SEPARATOR + filename    
    assert File.exists?(pathed_filename),
          "File.exists?(#{pathed_filename})"
    assert_equal expected_content, IO.read(pathed_filename)
    assert_equal executable, File.executable?(pathed_filename),
                            "File.executable?(pathed_filename)"
  end
  
end

