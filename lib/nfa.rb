NFANode = Struct.new(
    :edges,
    :destinations,
    :epsilon_destinations,
    :is_final_destination,
    keyword_init: true
)
NFA = Struct.new(
    :from,
    :to,
    keyword_init: true
)

def build(term)
  case
  # アルファベット
  when term.has_key?(:asta) && term[:asta] == false
    build_nfa_from_alphabet term
  # 閉包
  when term.has_key?(:asta) && term[:asta]
    build_nfa_from_closure term
  # 連接
  when term.has_key?(:left_closure)
    build_nfa_from_connection term
  # 和
  when term.has_key?(:plus)
  build_nfa_from_union term
  end
end

def build_nfa_from_alphabet(alphabet)
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
  NFA.new(from: from, to: to)
end

def build_nfa_from_closure(closure)
  # 苦しい, アルファベットもハッシュを返すべき
  nfa = build asta: false, atom: closure[:atom]

  nfa.from.epsilon_destinations.push nfa.to
  nfa.to.epsilon_destinations.push nfa.from
  nfa
end

def build_nfa_from_connection(connection)
  left = build connection[:left_closure]

  if connection[:right_connection].nil?
    return left
  end

  # TODO: right_connectionにalphabetが入っていてもいいようにしたい。そうすればここの判定が不要になる
  right =
    if connection[:right_connection][:right_connection].nil?
      build connection[:right_connection][:left_closure]
    else
      build connection[:right_connection]
    end

  left.to.is_final_destination = false
  left.to.epsilon_destinations.push right.to

  NFA.new(from: left.from, to: right.to)
end

def build_nfa_from_union(union)
  # TODO: TERMにTYPEを持たせる。そうすればここの判定が不要になる
  # 実質、和ではないとき
  return build union[:left_connection] unless union[:plus]

  left = build union[:left_connection]
  right = build union[:right_union]

  start = NFANode.new(
    edges: [],
    destinations: [],
    epsilon_destinations: [],
    is_final_destination: false,
  )

  goal = NFANode.new(
      edges: [],
      destinations: [],
      epsilon_destinations: [],
      is_final_destination: true,
  )

  left.to.is_final_destination = false
  right.to.is_final_destination = false
  start.epsilon_destinations.push right.from
  start.epsilon_destinations.push left.from
  left.to.epsilon_destinations.push goal
  right.to.epsilon_destinations.push goal

  NFA.new(from: start, to: goal)
end
