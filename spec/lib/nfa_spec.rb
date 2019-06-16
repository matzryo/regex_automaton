require 'spec_helper'
require 'regex'
require 'nfa'
require 'json'

describe 'build_nfa_from_alphabet' do
  it '正常系' do
    alphabet, _pointer = parse_closure('a', 0)

    to = NFANode.new(
        edges: [],
        destinations: [],
        epsilon_destinations: [],
        is_final_destination: true,
    )

    from = NFANode.new(
        edges: [alphabet[:atom]],
        destinations: [to],
        epsilon_destinations: [],
        is_final_destination: false,
    )

    expect(build_nfa_from_alphabet(alphabet)).to eq(NFA.new(from: from, to: to))
  end
end

describe 'build_nfa_from_closure' do
  it '正常系' do
    closure, _pointer = parse_closure('a*', 0)
    from = NFANode.new(
        edges: ['a'],
        destinations: [],
        epsilon_destinations: [],
        is_final_destination: false,
    )

    to = NFANode.new(
        edges: [],
        destinations: [],
        epsilon_destinations: [],
        is_final_destination: true,
        )
    from.destinations.push to

    from.epsilon_destinations.push to
    to.epsilon_destinations.push from

    expect(build_nfa_from_closure(closure)).to eq(
                                                   NFA.new(
                                                         from: from,
                                                          to: to,
                                                   )
                                               )
  end
end

describe 'build_nfa_from_connection' do
  it '左と右のNFAをイプシロン遷移でつなげたオートマトンを返す' do
    connection, _pointer = parse_connection('ab', 0)

    right_to = NFANode.new(
        edges: [],
        destinations: [],
        epsilon_destinations: [],
        is_final_destination: true,
        )


    right_from = NFANode.new(
        edges: ['b'],
        destinations: [],
        epsilon_destinations: [],
        is_final_destination: false,
        )

    right_from.destinations.push right_to

    right = NFA.new(from: right_from, to: right_to)

    left_to = NFANode.new(
        edges: [],
        destinations: [],
        epsilon_destinations: [right.to],
        is_final_destination: false,
        )

    left_from = NFANode.new(
        edges: ['a'],
        destinations: [],
        epsilon_destinations: [],
        is_final_destination: false,
        )

    left_from.destinations.push left_to

    left = NFA.new(from: left_from, to: left_to)

    answer = NFA.new(from: left.from, to: right.to)

    expect(build_nfa_from_connection(connection)).to eq(answer)
  end
end
