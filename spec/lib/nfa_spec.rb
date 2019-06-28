require 'spec_helper'
require 'regex'
require 'nfa'
require 'json'

describe 'build_nfa_from_alphabet' do
  it '正常系' do
    alphabet, _pointer = parse_closure('a', 0)

    to = NFANode.new(
        edges: {},
        epsilon_edges: [],
        is_final_destination: true,
    )

    from = NFANode.new(
        edges: {alphabet[:atom] => to},
        epsilon_edges: [],
        is_final_destination: false,
    )

    expect(build_nfa_from_alphabet(alphabet)).to eq(NFA.new(from: from, to: to))
  end
end

describe 'build_nfa_from_closure' do
  it '正常系' do
    closure, _pointer = parse_closure('a*', 0)
    from = NFANode.new(
        edges: {},
        epsilon_edges: [],
        is_final_destination: false,
    )

    to = NFANode.new(
        edges: {},
        epsilon_edges: [],
        is_final_destination: true,
    )
    from.edges['a'] = to

    from.epsilon_edges.push to
    to.epsilon_edges.push from

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
        edges: {},
        epsilon_edges: [],
        is_final_destination: true,
    )


    right_from = NFANode.new(
        edges: {},
        epsilon_edges: [],
        is_final_destination: false,
    )

    right_from.edges['b'] = right_to

    right = NFA.new(from: right_from, to: right_to)

    left_to = NFANode.new(
        edges: {},
        epsilon_edges: [right.to],
        is_final_destination: false,
    )

    left_from = NFANode.new(
        edges: {},
        epsilon_edges: [],
        is_final_destination: false,
    )

    left_from.edges['a'] = left_to

    left = NFA.new(from: left_from, to: left_to)

    answer = NFA.new(from: left.from, to: right.to)

    expect(build_nfa_from_connection(connection)).to eq(answer)
  end
end

describe 'build_nfa_from_union' do
  it '和の初期状態から左と右の初期状態にイプシロン遷移を追加、左と右の受理状態から和の受理状態につなげたオートマトンを返す' do
    parsed_left, _pointer = parse_connection('a', 0)
    parsed_right, _pointer = parse_union('b', 0)
    left = build(parsed_left)
    right = build(parsed_right)

    start = NFANode.new(
        edges: {},
        epsilon_edges: [],
        is_final_destination: false
    )


    goal = NFANode.new(
        edges: {},
        epsilon_edges: [],
        is_final_destination: true,
    )

    left.to.is_final_destination = false
    right.to.is_final_destination = false
    start.epsilon_edges.push right.from
    start.epsilon_edges.push left.from
    left.to.epsilon_edges.push goal
    right.to.epsilon_edges.push goal

    expected = NFA.new(from: start, to: goal)

    parsed_union, _pointer = parse_union('a+b', 0)
    expect(build_nfa_from_union(parsed_union)).to eq(expected)
  end
end
