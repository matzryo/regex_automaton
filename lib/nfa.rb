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
  when term.has_key?(:asta) && term[:asta] == false
    # アルファベット
    build_nfa_from_alphabet term
  when term.has_key?(:asta) && term[:asta]
    # 閉包
    build_nfa_from_closure term
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
  am = build asta: false, atom: closure[:atom]

  am.from.epsilon_destinations.push am.to
  am.to.epsilon_destinations.push am.from
  am
end

# def build_nfa_from_connection(connection)
#   to = NFANode.new(
#       edges: [],
#       destinations: [],
#       epsilon_destinations: [],
#       is_final_destination: true,
#       )
#
#   from = NFANode.new(
#       edges: [connection[:atom], :epsilon],
#       destinations: [to, to],
#       epsilon_destinations: [],
#       is_final_destination: false,
#       )
#
#   NFA.new(from: from, to: to)
# end
