require './args.rb'

module SandboxArgs

  class CmdArgument

    protected

    @val
    @mean
    @klass

    public

    attr_reader :val, :mean

    def initialize(val, mean, klass)
      @val = val
      @mean = mean
      @klass = klass

      raise 'Wrong arg type' if val != nil && !val.kind_of?(klass)
    end

    def self.wrong_value
      raise 'Virtual method called!'
    end

    def self.correct_value
      raise 'Virtual method called!'
    end

    def mean
      @mean
    end

    def val=(obj)
      @val = obj

      raise 'Wrong arg type' unless val.kind_of?(@klass)
    end

    def to_s
      @val.to_s
    end

  end

  class TimeLimitArgument < CmdArgument

    def initialize(val = nil)
      super val, :time_limit, Args::TimeArgument
    end

    def self.wrong_value
      Args::SecondsArgument.new(0)
    end

    def self.correct_value
      Args::SecondsArgument.new(1)
    end

  end

  class MemoryLimitTypeArgument < CmdArgument

    def initialize(val, mean)
      super val, mean, Args::MemoryArgument
    end

    def self.wrong_value
      Args::KilobyteArgument.new(0)
    end

    def self.correct_value
      Args::KilobyteArgument.new(1)
    end

  end

  class MemoryLimitArgument < MemoryLimitTypeArgument

    def initialize(val = nil)
      super val, :memory_limit
    end

  end

  class WriteLimitArgument < MemoryLimitTypeArgument

    def initialize(val = nil)
      super val, :write_limit
    end

  end

  class FileArgumentType < CmdArgument

    def initialize(val, mean)
      super val, mean, Args::FileArgument
    end

    def self.correct_value(filename)
      Args::FileArgument.new(filename)
    end

    def self.wrong_value
      Args::FileArgument.new('"L:\Some\Unknown\Folder\On\Not\Existing\HDD\file.txt"')
    end

  end

  class InputFileArgument < FileArgumentType

    def initialize(val = nil)
      super val, :input
    end

    def self.correct_value
      filename = 'file.txt'

      File.open(filename, 'w') { |f| f.write('') }

      super filename
    end

  end

  class OutputFileArgument < FileArgumentType

    def initialize(val = nil)
      super val, :output
    end

    def self.correct_value
      super 'some_output.txt'
    end

  end

  class ErrorFileArgument < FileArgumentType

    def initialize(val = nil)
      super val, :error
    end

    def self.correct_value
      super 'some_error.txt'
    end

  end

  class WorkingDirectoryArgument < CmdArgument

    def initialize(val = nil)
      super val, :directory, Args::DirectoryArgument
    end

    def self.wrong_value
      Args::DirectoryArgument.new('"L:\Some\Unknown\Folder\On\Not\Existing\HDD"')
    end

    def self.correct_value
      Args::DirectoryArgument.new('.')
    end

  end

  class UserCredentialsArgument < CmdArgument

    def initialize(val = nil)
      super val, :authentication, Args::UserCredentialsArgument
    end

    def self.correct_value
      string = Args::StringArgument

      Args::UserCredentialsArgument.new(string.new('Artem'), string.new('123456'))
    end

    def self.wrong_value
      string = Args::StringArgument

      Args::UserCredentialsArgument.new(string.new, string.new)
    end

  end

  class IdlenessLimitArgument < CmdArgument

    def initialize(val = nil)
      super val, :idleness, Args::IdlenessLimitArgument
    end

    def self.correct_value
      Args::IdlenessLimitArgument.new(Args::PercentArgument.new(15), Args::SecondsArgument.new(1))
    end

    def self.wrong_value
      Args::IdlenessLimitArgument.new(Args::PercentArgument.new(0), Args::SecondsArgument.new(0))
    end

  end

  class FlagArgument < CmdArgument

    def initialize(val, mean)
      super val, mean, Args::FlagArgument
    end

    def self.correct_value
      Args::FlagArgument.new(true)
    end

    def self.wrong_value
      Args::FlagArgument.new(-1)
    end

  end

  class HideReportFlag < FlagArgument

    def initialize(val = true)
      super Args::FlagArgument.new(val), :hide_report
    end

  end

  class EnumArgument < CmdArgument

    protected

    @@allowed_values

    def raise_if_wrong_type(val)
      raise 'Wrong type for value!' if !val.nil? and @allowed_values.include?(val.val)
    end

    public

    attr_reader :allowed_values

    def initialize(val, mean, allowed)
      super val, mean, Args::StringArgument

      @@allowed_values = allowed

      raise_if_wrong_type(val)
    end

    def val=(val)
      raise_if_wrong_type(val)

      @val = val
    end

    def self.correct_value
      Args::StringArgument.new(@@allowed_values.sample)
    end

    def self.wrong_value
      wrong = ''

      wrong += '1' while @@allowed_values.include?(wrong)

      Args::StringArgument.new(wrong)
    end

  end

  class ArrayArgument < CmdArgument

    def initialize(val, mean)
      super val, mean, Args::ArrayArgument
    end

  end

  class EnvironmentVariablesArgument < ArrayArgument

    def initialize(val = nil)
      super val, :environment_vars
    end

    def self.correct_value
      Args::ArrayArgument.new(['var=val'])
    end

    def self.wrong_value
      Args::ArrayArgument.new(['1345'])
    end

  end

end