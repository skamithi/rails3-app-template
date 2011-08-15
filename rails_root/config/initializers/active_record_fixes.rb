module NullifyBlankAttributes
  def write_attribute(attr_name, value)
    new_value = value.presence
    super(attr_name, new_value)
  end
end

class ActiveRecord::Base
  include NullifyBlankAttributes
end

