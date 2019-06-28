require 'spec_helper'
require 'regex'
require 'nfa'
require 'json'
require 'dfa'

describe 'build_nfa_from_alphabet' do
  it "1文字" do
    alphabet = lexical_analysis('a')
    nfa = build(alphabet)
    dfa = convert(nfa)
    expect(dfa).to eq(
        DFA.new(
          from: DFANode.new(
            edges: {
              "a" => DFANode.new(is_final_destination: true)
            },
            is_final_destination: false,
          )
        )
      )
  end
end

describe "does_accept" do
  context "アルファベット" do
    let(:answer) {
      alphabet = lexical_analysis('a')
      nfa = build(alphabet)
      dfa = convert(nfa)
      does_accept(dfa, string)
    }
    context "受け入れるとき" do
      let(:string) { 'a' }
      it "trueを返す" do
        expect(answer).to eq(true)
      end
    end
    context "受け入れないとき" do
      let(:string) { 'b' }
      it "falseを返す" do
        expect(answer).to eq(false)
      end
    end
  end
end
