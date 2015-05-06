module Args

  class Argument
    @val

    def initialize(val)
      @val = val
    end

    def val
      @val
    end

    def val=(val)
      @val = val
    end

    def to_s
      @val.to_s
    end

    def to_f
      @val.to_f
    end

    def self.wrong_value
      raise 'Virtual method called!'
    end

    def self.correct_value
      raise 'Virtual method called!'
    end
  end

  class TimeArgument < Argument

    def self.wrong_value
      TimeArgument.new(0)
    end

    def self.correct_value
      TimeArgument.new(1)
    end

  end

  class MillisecondsArgument < TimeArgument
  end

  class SecondsArgument < TimeArgument
  end

  class MinutesArgument < TimeArgument

    def to_seconds
      SecondsArgument.new(@val * 60)
    end

  end

  class StringArgument < Argument

    def self.wrong_value
      StringArgument.new('')
    end

    def self.correct_value
      StringArgument.new('aaa')
    end

  end

  class FileArgument < StringArgument

    def self.wrong_value
      FileArgument.new('"L:\Some\Unknown\Folder\On\Not\Existing\HDD\file.txt"')
    end

    def self.correct_value
      FileArgument.new('./file.txt')
    end

  end

  class DirectoryArgument < StringArgument

    def self.wrong_value
      DirectoryArgument.new('"L:\Some\Unknown\Folder\On\Not\Existing\HDD"')
    end

    def self.correct_value
      DirectoryArgument.new('.')
    end

  end

  class PercentArgument < Argument

    def self.wrong_value
      PercentArgument.new(-1)
    end

    def self.correct_value
      PercentArgument.new(50)
    end

    def to_s
      sprintf('%.2f', @val / 100.0)
    end

  end

  class MemoryArgument < Argument

    def self.wrong_value
      MemoryArgument.new(-1)
    end

    def self.correct_value
      MemoryArgument.new(1)
    end

  end

  class ByteArgument < MemoryArgument
  end

  class KilobyteArgument < MemoryArgument
  end

  class MegabyteArgument < MemoryArgument
  end

  class GigabyteArgument < MemoryArgument

    def to_bytes
      ByteArgument.new(@val * (1 << 20))
    end

  end

end