require 'spec_helper'
require 'reg'

describe 'test' do
  it 'test' do
    expect(true).to eq(true)
  end
end

describe '#parse_atom' do
  it '一文字だけパース' do
    tree, pointer = parse_atom("abc", 0)
    expect(tree).to eq('a')
    expect(pointer).to eq(1)
  end
  it 'カッコ' do
    tree, pointer = parse_atom("(a)", 0)
    expect(tree).to eq({
                           plus: false,
                           left_connection: {
                               left_closure: {
                                   asta: false,
                                   atom: "a"
                               },
                               right_connection: nil
                           },
                           right_union: nil,

                       })
    expect(pointer).to eq(3)
  end
  describe "異常" do
    it '長さ以上のポインター' do
      tree, pointer = parse_atom("abc", 3)
      expect(tree).to eq(nil)
      expect(pointer).to eq(3)
    end
  end
end

describe '#parse_closure' do
  it 'アスタリスクあり' do
    tree, pointer = parse_closure("a*b", 0)
    expect(tree).to eq({
                        asta: true,
                        atom: 'a'
                       })
    expect(pointer).to eq(2)
  end
  it 'アスタリスクなし' do
    tree, pointer = parse_closure("ab", 0)
    expect(tree).to eq({
                           asta: false,
                           atom: 'a'
                       })
    expect(pointer).to eq(1)
  end
  it '最終字(アスタリスクあり)' do
    tree, pointer = parse_closure("abc*", 2)
    expect(tree).to eq({
                           asta: true,
                           atom: 'c'
                       })
    expect(pointer).to eq(4)
  end
  it '最終字(アスタリスクなし)' do
    tree, pointer = parse_closure("abc", 2)
    expect(tree).to eq({
                           asta: false,
                           atom: 'c'
                       })
    expect(pointer).to eq(3)
  end
  describe "異常" do
    it '長さ以上のポインター' do
      tree, pointer = parse_closure("abc*", 4)
      expect(tree).to eq(nil)
      expect(pointer).to eq(4)
    end
  end
end

describe '#parse_connection' do
  it 'シンプルパターン　' do
    tree, pointer = parse_connection("ab", 0)
    expect(tree).to eq({
                           left_closure: {
                               asta: false,
                               atom: "a"
                           },
                           right_connection: {
                               left_closure: {
                                   asta: false,
                                   atom: "b"
                               },
                               right_connection: nil
                           }
                       })
    expect(pointer).to eq(2)

  end
  it '適当に複雑なパターン' do
    tree, pointer = parse_connection("a*bc*", 0)
    expect(tree).to eq({
                           left_closure: {
                             asta: true,
                             atom: "a"
                           },
                           right_connection: {
                               left_closure: {
                                   asta: false,
                                   atom: "b"
                                },
                               right_connection: {
                                   left_closure: {
                                     asta: true,
                                     atom: "c"
                                   },
                                   right_connection: nil
                               }
                           }
                       })
    expect(pointer).to eq(5)
  end
end

describe "#parse_union" do
  it 'シンプルパターン　' do
    tree, pointer = parse_union("a+b", 0)
    expect(tree).to eq({
                           plus: true,
                           left_connection: {
                              left_closure: {
                                  asta: false,
                                  atom: "a"
                              },
                              right_connection: nil
                           },
                           right_union: {
                               plus: false,
                               left_connection: {
                                   left_closure: {
                                       asta: false,
                                       atom: "b"
                                   },
                                   right_connection: nil,
                               },
                               right_union: nil
                           },
                       })
    expect(pointer).to eq(3)
  end
  it '+無し' do
    tree, pointer = parse_union("ab", 0)
    expect(tree).to eq({
                           plus: false,
                           left_connection: {
                               left_closure: {
                                   asta: false,
                                   atom: "a",
                               },
                               right_connection: {
                                   left_closure: {
                                       asta: false,
                                       atom: "b",
                                   },
                                   right_connection: nil,
                               }
                           },
                           right_union: nil,
                       })
    expect(pointer).to eq(2)
  end
end

describe "lexical_analysis" do
  it "アトム(アルファベット)" do
    tree = lexical_analysis("a")
    expect(tree).to eq({
                           plus: false,
                           left_connection: {
                               left_closure: {
                                   asta: false,
                                   atom: "a",
                               },
                               right_connection: nil,
                           },
                           right_union: nil,
                       })
  end
  it "アトム(カッコ)" do
    tree, pointer = parse_atom("(a)", 0)
    expect(tree).to eq({
                           plus: false,
                           left_connection: {
                               left_closure: {
                                   asta: false,
                                   atom: "a"
                               },
                               right_connection: nil
                           },
                           right_union: nil,

                       })
    expect(pointer).to eq(3)
  end
  it "閉包" do
    tree = lexical_analysis("a*")
    expect(tree).to eq({
                           plus: false,
                           left_connection: {
                               left_closure: {
                                   asta: true,
                                   atom: "a",
                               },
                               right_connection: nil,
                           },
                           right_union: nil,
                       })
  end
  it "連接" do
    tree = lexical_analysis("ab")
    expect(tree).to eq({
                           plus: false,
                           left_connection: {
                               left_closure: {
                                   asta: false,
                                   atom: "a",
                               },
                               right_connection: {
                                   left_closure: {
                                       asta: false,
                                       atom: "b",
                                   },
                                   right_connection: nil,
                               },
                           },
                           right_union: nil,
                       })
  end
  it '和　' do
    tree = lexical_analysis("a+b")
    expect(tree).to eq({
                           plus: true,
                           left_connection: {
                               left_closure: {
                                   asta: false,
                                   atom: "a"
                               },
                               right_connection: nil
                           },
                           right_union: {
                               plus: false,
                               left_connection: {
                                   left_closure: {
                                       asta: false,
                                       atom: "b"
                                   },
                                   right_connection: nil,
                               },
                               right_union: nil
                           },
                       })
  end
end
