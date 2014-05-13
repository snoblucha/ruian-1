# not a really queue

class Ruian
  class Queue
    attr_accessor :importer

    def initialize(importer)
      self.importer = importer
    end

    def push(obj)
      key = obj.class.to_s.split('::').last.downcase
      callback(key, obj)
    end

    def callback(key, obj)
      self.importer.send(callback_key(key), obj)
    end

    def callback_key(key)
      "import_#{key}"
    end
  end
end
