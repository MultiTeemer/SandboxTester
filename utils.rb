require 'test/unit'
require 'fileutils'
require 'json'
require './compilers.rb'
require './wrappers.rb'

module Utils

	def self.system_dir?(dir)
		%w[ . .. .idea .git ].include? dir
  end

  def self.get_compiler_for(source)
      extension = file_extension(source)

      case extension
        when 'cpp' then Compilers::GCCCompilerWrapper.new
        when 'pas' then Compilers::PascalCompilerWrapper.new
        when 'abc' then Compilers::PascalABCCompilerWrapper.new
        when 'cs' then Compilers::CSharpCompilerWrapper.new
        when 'rb' then Compilers::RubyInterpreterWrapper.new
        when 'py' then Compilers::PythonInterpreterWrapper.new
        else raise 'Wrong extension for test file!'
      end
  end

  def self.file_extension(filename)
    File.extname(filename).delete('.')
  end

  def self.file_name(path)
    File.basename(path).delete(File.extname(path))
  end

  def self.get_dir_name(test_name)
    test_name.slice(5, test_name.length)
  end

  def self.compile_for_test(test_name)
    tests_folder = "src/#{get_dir_name(test_name)}"

    Dir.foreach(tests_folder) do |source|
      unless system_dir?(source)
        full_path = "#{tests_folder}/#{source}"
        output_path = 'bin/'

        if File.file?(full_path)
          get_compiler_for(full_path).compile(full_path, output_path)
        else
          json = Dir.entries(full_path).select { |entry| entry == 'metadata.json' }

          if json.length == 0
            Compilers::JavaInterpretableWrapper.new.compile(full_path, output_path)
          else
            test_metadata = JSON.parse(IO.read(full_path + '/' + json[0]))['test']
            order = test_metadata['order']
            out = output_path + source

            Dir.mkdir(out) unless Dir::exist?(out)

            raise 'Order of file doesn\'t specified!' if order.nil?

            order.each_index do |i|
              curr = full_path + '/' + order[i]

              get_compiler_for(curr).compile(curr, out, sprintf('%02d', i))
            end
          end
        end
      end
    end
  end

  def self.clear
    FileUtils.rm_rf('bin')
  end

  @sandbox = nil

  def self.sandbox
    @sandbox
  end

  def self.init_spawner(type, path)
    @sandbox = (case type
      when 'cats' then Wrappers::CatsSpawnerWrapper
      when 'pcms2' then Wrappers::PCMS2RunWrapper
      else nil
    end).new(path)
  end

end
