require 'fileutils'

module Compilers

  class CompilerWrapper
    @cmd
    @out_arg

    attr_accessor :cmd,
                  :out_arg

    def initialize(run_command, output_argument)
      @cmd = run_command
      @out_arg = output_argument
    end

    def compile(source, output_dir, output_name = nil)
      outname = (output_name || Utils.file_name(source)) + '.exe'

      system("#{@cmd} #{@out_arg}#{output_dir + '/' + outname} #{source} 1>nul 2>nul")
    end

  end

  class GCCCompilerWrapper < CompilerWrapper

    def initialize
      super 'g++', '-o '
    end

  end

  class PascalCompilerWrapper < CompilerWrapper

    def initialize
      super 'fpc', '-o'
    end

    def compile(source, output_dir, output_name = nil)
      super

      File.delete(output_dir + Utils.file_name(source) + '.o')
    end

  end

  class PascalABCCompilerWrapper < CompilerWrapper

    def initialize
      super 'pabcnetc', ''
    end

    def compile(source, output_dir, output_name = nil)
      basename = output_name || Utils.file_name(source)
      source_copy = basename + '.pas'
      compiled = basename + '.exe'

      FileUtils.cp(source, source_copy)

      system("#{@cmd} #{source_copy} 1>nul")

      FileUtils.cp(compiled, output_dir + '/' + compiled)
      [source_copy, compiled].each{ |filename| File.delete(filename) }
    end

  end

  class CSharpCompilerWrapper < CompilerWrapper

    def initialize
      super 'csc', '/out:'
    end

    def compile(source, output_dir, output_name = nil)
      Dir.chdir(source.split(/\//).slice(0, 2).join('/'))
      super File.basename(source), '../../' + output_dir, output_name
      Dir.chdir('../..')
    end

  end

  class InterpretableCompilerWrapper < CompilerWrapper

    def initialize(cmd)
      super cmd, nil
    end

    def compile(source, output_dir, output_name = nil)
      compiled = output_name || File.basename(source)
      compiled += File.extname(source) if output_name

      FileUtils.cp(source, output_dir + '/' + compiled)
    end

  end

  class RubyInterpreterWrapper < InterpretableCompilerWrapper

    def initialize
      super 'ruby'
    end

  end

  class PythonInterpreterWrapper < InterpretableCompilerWrapper

    def initialize
      super 'python'
    end

  end

  class JavaInterpretableWrapper < InterpretableCompilerWrapper

    def initialize
      super 'java'
    end

    def compile(source, output)
      file = (Dir.entries(source) - %w[ . .. ])[0]
      binary = output + File.basename(source)

      FileUtils::mkdir_p(binary)

      system("javac -d #{binary} #{source + '/' + file} 1>nul 2>nul")
    end

  end

end
