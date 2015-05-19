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
  end

  class TimeArgument < Argument

    def to_ms
      raise 'Virtual method called!'
    end

  end

  class MillisecondsArgument < TimeArgument

    def to_ms
      self.clone
    end

  end

  class SecondsArgument < TimeArgument

    def to_ms
      MillisecondsArgument.new(@val * 1000)
    end

  end

  class MinutesArgument < TimeArgument

    def to_ms
      MillisecondsArgument.new(@val * 1000 * 60)
    end

  end

  class StringArgument < Argument

    def initialize(val = '')
      super
    end

    def to_f
      raise 'Virtual method called!'
    end

  end

  class FileArgument < StringArgument
  end

  class DirectoryArgument < StringArgument
  end

  class PercentArgument < Argument

    def to_s
      sprintf('%.2f', @val / 100.0)
    end

  end

  class MemoryArgument < Argument

    def to_bytes
      raise 'Virtual method called!'
    end

  end

  class ByteArgument < MemoryArgument

    def to_bytes
      self.clone
    end

  end

  class KilobyteArgument < MemoryArgument

    def to_bytes
      ByteArgument.new(@val * (1 << 10))
    end

  end

  class MegabyteArgument < MemoryArgument

    def to_bytes
      ByteArgument.new(@val * (1 << 20))
    end

  end

  class GigabyteArgument < MemoryArgument

    def to_bytes
      ByteArgument.new(@val * (1 << 30))
    end

  end

  class ComplexArgument < Argument

    def initialize
      @val = nil
    end

    def to_s
      raise 'Virtual method called!'
    end

    def to_f
      raise 'Virtual method called!'
    end

  end

  class UserCredentialsArgument < ComplexArgument

    private

    @username
    @password

    public

    attr_accessor :username, :password

    def initialize(username, password)
      @username = username
      @password = password

      raise 'Wrong type(s) of arg(s)!' unless username.kind_of?(StringArgument) and password.kind_of?(StringArgument)
    end

  end

  class IdlenessLimitArgument < ComplexArgument

    private

    @required_load
    @idleness

    public

    attr_accessor :required_load, :idleness

    def initialize(required_load, idleness)
      @required_load = required_load
      @idleness = idleness

      raise 'Wrong type(s) of arg(s)!' unless required_load.kind_of?(PercentArgument) and idleness.kind_of?(TimeArgument)
    end

  end

  class FlagArgument < Argument

    def initialize(val = true)
      super
    end

    def to_s
      if @val.instance_of?(TrueClass) or @val.instance_of?(FalseClass)
        @val ? '1' : '0'
      else
        super
      end
    end

  end

  class ArrayArgument < Argument

    def initialize(val)
      super

      @val = [@val] unless @val.instance_of?(Array)
    end

  end

end