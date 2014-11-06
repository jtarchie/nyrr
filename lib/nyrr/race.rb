module NYRR
  Race = Struct.new(:name) do
    def initialize(*)
      super
      raise AttributeRequired, 'Missing attribute name' unless name
    end

    def search(max = 100)
      NYRR::Search.new(self, max)
    end
  end
end
