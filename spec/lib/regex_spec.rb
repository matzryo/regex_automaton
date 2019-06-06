require 'spec_helper'
require 'reg'

describe 'test' do
  it 'test' do
    expect(true).to eq(true)
  end
end

describe 'atom解析' do
  it '一文字' do
    tree = lexical_analysis("a")
    expect(tree).to eq({
                           :union=> {
                              :left_connection=> {
                                  :connection=> {
                                      :left_closure => {
                                          :closure => {
                                              :atom =>"a"
                                          }
                                      },
                                      :right_closure => nil
                                  }
                              },
                              :right_connection => nil
                          }
                       }
                    )
  end
end