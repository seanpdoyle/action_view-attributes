module AttributesAndTokenLists
  class TokenList # :nodoc:
    include Enumerable

    def self.split(tokens)
      tokens.to_s.split(/\s+/)
    end

    def self.wrap(value)
      if value.is_a? TokenList
        value
      else
        tokens =
          case value
          when Enumerable then value
          else Array(value)
          end

        new tokens.flat_map { |token| split(token) }.reject(&:blank?)
      end
    end

    def initialize(tokens)
      @tokens = Set[*tokens]
    end

    def union(other)
      TokenList.wrap(@tokens.union(Set[*other]))
    end
    alias_method :merge, :union
    alias_method :+, :union
    alias_method :|, :union

    def each(&block)
      @tokens.each(&block)
    end

    def ==(other)
      Array(@tokens) == Array(other)
    end

    def to_s
      to_a.join(" ")
    end
  end
end
