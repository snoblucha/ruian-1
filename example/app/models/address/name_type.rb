module Address
  class NameType < Hex::Enum
    FIRST_NAME = new(1, 'first_name')
    LAST_NAME = new(2, 'last_name')
  end
end