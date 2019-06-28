DFANode = Struct.new(
    :edges,
    :is_final_destination,
    keyword_init: true
)
DFA = Struct.new(
    :from,
    keyword_init: true
)
def convert(nfa)
  first_node_set = get_nodes_connected_by_epsilon(nfa.from)
  determined_start_node = DFANode.new(is_final_destination: false)

  # NFAのノード集合と、DFAのノードを対応付ける
  determined_nodes = {
      # ノードの集合がキー、ひとつののノードがバリュー
      first_node_set => determined_start_node
  }

  queue = [first_node_set]
  visited = Set.new

  while !queue.empty?
    target_set = queue.shift
    next_node = determined_nodes[target_set]
    visited.add(next_node)

    labels = {}

    # 遷移先をまとめる
    target_set.each do |node_from|
      node_from.edges.each do |char, nfa_node|
        # なければ初期化
        unless labels.has_value? char
          labels[char] = Set.new([nfa_node])
        else
          labels[char].add(nfa_node)
        end

        labels[char].merge(nfa_node.epsilon_edges)
      end
    end

    labels.each do |char, nfa_node_set|
      if determined_nodes.has_key? nfa_node_set
        n = determined_nodes[nfa_node_set]
        next_node.edges[char].push n
        unless visited.member? n
          queue.push nfa_node_set
        end
      else
        n = DFANode.new(is_final_destination: false)
        determined_nodes[nfa_node_set] = n
        queue.push nfa_node_set
        next_node.edges = {char => Set.new([n])}
      end
    end
  end

  determined_nodes.each do |node_set, node|
    node_set.each do |n|
      if n.is_final_destination
        node.is_final_destination = true
        break
      end
    end
  end

  DFA.new(from: determined_start_node)
end

def get_nodes_connected_by_epsilon(nfa_node)
  visited = Set[nfa_node]
  queue = [nfa_node]

  while !queue.empty?
    target_node = queue.shift

    target_node.epsilon_edges.each do |epsilon_edge|
      next if visited.member? epsilon_edge

      queue.push epsilon_edge
      visited.add epsilon_edge
    end
  end

  visited
end
