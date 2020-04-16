module ContractErrorDemo
  class << self
    def call
      contract.transform!(invalid_data)
    end

    private

    def invalid_data # rubocop:disable Metrics/MethodLength
      {
        str_array_field: ['aaa', 'bbb', :ccc],
        hash_array_field: [
          {
            x: 1,
            y: 2
          },
          {
            'x' => 1,
            'y' => 2
          }
        ],
        array_compose_predicate: ['aaaa', 'bbbb', 'a', :xxx],
        int_field: '10',
        array_either: ['a', :a, 1],
        tuple: [1, 1]
      }
    end

    def contract # rubocop:disable Metrics/MethodLength
      Flows::Contract.make do
        hash_of(
          str_array_field: array(String),
          hash_array_field: array(
            hash(Symbol, String)
          ),
          array_compose_predicate: array(
            compose(String, predicate('must be longer that 3') { |str| str.size > 3 })
          ),
          int_field: Integer,
          array_either: array(
            either(String, Symbol)
          ),
          tuple: tuple(Float, Float),
          field_to_be_missed: String
        )
      end
    end
  end
end
