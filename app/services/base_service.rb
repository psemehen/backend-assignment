require "ostruct"

class BaseService
  def self.call(*args, &block)
    new(*args, &block).call
  end

  def success(data = {})
    OpenStruct.new(success?: true, errors: [], **data)
  end

  def failure(errors, data = {})
    OpenStruct.new(success?: false, errors: Array(errors), **data)
  end
end
