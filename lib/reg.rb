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
  return [nil, Float::INFINITY] if statement.length <= pointer

  char = statement.slice(pointer)

  case char
  when '('
    pointer += 1
    union_in_parenthesis, pointer = parse_union(statement, pointer)
    return [{union_in_parenthesis: union_in_parenthesis}, pointer]
  when 'a'..'z'
    pointer += 1
    return [{atom: char}, pointer]
  else
    return [nil, Float::INFINITY]
  end
end

def parse_closure(statement, pointer)
  return [nil, Float::INFINITY] if statement.length <= pointer

  atom, pointer = parse_atom(statement, pointer)

  return [{closure: atom}, pointer] if statement.length <= pointer

  char = statement.slice(pointer)

  case char
  when '*'
    return [{astarisk: '*'}, pointer]
  else
    [{closure: atom}, pointer]
  end
end

def parse_connection(statement, pointer)
  return [nil, Float::INFINITY] if pointer > statement.length

  left_closure, pointer = parse_closure(statement, pointer)

  return [nil, Float::INFINITY] if left_closure.nil?

  right_closure, pointer = parse_connection(statement, pointer)

  if right_closure.nil?
    return [{connection: {left_closure: left_closure, right_closure: nil}}, pointer]
  end

  [{connection: {left_closure: left_closure, right_closure: right_closure}}, pointer]
end

def parse_union(statement, pointer)
  return [nil, Float::INFINITY] if pointer > statement.length

  left_connection, pointer = parse_connection(statement, pointer)

  return [nil, Float::INFINITY] if left_connection.nil?

  if (statement.length <= pointer || statement.slice(pointer) != '+')
    return [{union: {left_connection: left_connection, right_connection: nil}}, pointer]
  end

  pointer += 1

  right_connection, pointer = parse_union(statement, pointer)

  return [nil, Float::INFINITY] if (right_connection.nil?)

  [{union: {left_connection: left_connection, right_connection: right_connection}}, pointer]
end

# regex = gets.chomp

# p lexical_analysis regex

# atom, p = parse_atom(regex, 0)
# p atom
# closure, p = parse_closure(regex, 0)
# p closure
# connection, p = parse_connection(regex, 0)
# p connection
# union, p = lexical_analysis(regex)
# pp union



