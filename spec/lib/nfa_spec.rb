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
