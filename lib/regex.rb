# アルファベット ::= aからz
# alphabet ::= 'a' | ... | 'z'
#
# アトム ::= 一文字 | カッコ
# atom ::= alphabet | '(' plus ')'
#
# 閉包 ::= アトム*
# closure ::= atom | atom '*'
#
# 連接 ::= 閉包 | 閉包 閉包
# connection ::= closure | closure + closure
#
# 和 ::= 連接 | 連接 + 和
# union ::= connection | connection '+' union
#
# 正規表現 ::= 和
# regex ::= union

# def tokenize str
#   str.split ""
# end

# Alphabet = Struct.new(:type, :char, keyword_init: true)
# Closure = Struct.new(:type, :atom, keyword_init: true)
# Union = Struct.new(:type, :leftConnection, :rightUnion, keyword_init: true)
# Connection = Struct.new(:type, :leftClosure, :rightClosure, keyword_init: true)

def lexical_analysis(regex)
  parsed_regex, _pointer = parse_union regex, 0
  parsed_regex
end

def parse_atom(statement, pointer)
  return [nil, pointer] if pointer >= statement.length

  char = statement.slice(pointer)

  case char
  when '('
    pointer += 1
    union_in_parenthesis, pointer = parse_union(statement, pointer)
    pointer += 1 # 閉じカッコ, エラー出したほうがいいのかな
    return [union_in_parenthesis, pointer]
  when 'a'..'z'
    pointer += 1
    return [char, pointer]
  else
    # 例外
    return [nil, pointer]
  end
end

def parse_closure(statement, pointer)
  return [nil, pointer] if pointer >= statement.length

  atom, pointer = parse_atom(statement, pointer)

  return [{ asta: false, atom: nil }, pointer] if atom.nil?
  return [{ asta: false, atom: atom }, pointer] if pointer >= statement.length

  char = statement.slice(pointer)

  case char
  when '*'
    pointer += 1
    return [{ asta: true, atom: atom }, pointer]
  else
    [{ asta: false, atom: atom }, pointer]
  end
end

def parse_connection(statement, pointer)
  return [nil, pointer] if pointer >= statement.length

  left_closure, pointer = parse_closure(statement, pointer)

  return [nil, pointer] if left_closure[:atom].nil?

  right_connection, pointer = parse_connection(statement, pointer)

  return [{left_closure: left_closure, right_connection: nil}, pointer] if right_connection.nil?

  [{left_closure: left_closure, right_connection: right_connection}, pointer]
end

def parse_union(statement, pointer)
  return [nil, pointer] if pointer >= statement.length

  left_connection, pointer = parse_connection(statement, pointer)

  return [nil, pointer] if left_connection.nil?

  if (pointer >= statement.length) || (statement.slice(pointer) != '+')
    return [{plus: false, left_connection: left_connection, right_union: nil}, pointer]
  end

  pointer += 1

  right_union, pointer = parse_union(statement, pointer)

  return [nil, pointer] if (right_union.nil?)

  [{plus: true, left_connection: left_connection, right_union: right_union}, pointer]
end

