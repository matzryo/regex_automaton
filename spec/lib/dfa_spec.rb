require 'spec_helper'
require 'regex'
require 'nfa'
require 'json'
require 'dfa'

describe 'build_nfa_from_alphabet' do
  it "DFAに変換できている" do
    alphabet = lexical_analysis('a')
    nfa = build(alphabet)
    dfa = convert(nfa)
    expect(dfa).to eq(
                       DFA.new(
                              from: DFANode.new(
                                               edges: {
                                                   "a" => Set.new([
                                                               DFANode.new(is_final_destination: true)
                                                   ])
                                               },
                                               is_final_destination: false,
                              )
                       )
                   )
  end
end
