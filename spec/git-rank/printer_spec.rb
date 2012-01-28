#!/usr/bin/env rspec

require 'spec_helper'
require 'git-rank/printer'

describe GitRank::Printer do
  let(:author_info) { {
    "Matt Robinson" => { 
      'foo' => {:additions => 1, :deletions => 0, :total => 1, :net => 1 },
      'bar' => {:additions => 0, :deletions => 2, :total => 2, :net => 1 }, 
      'baz' => {:additions => 3, :deletions => 7, :total => 10, :net => -4} },
    "Rob Mattinson" => { 
      'foo' => {:additions => 2, :deletions => 1, :total => 3, :net => 1 },
      'bar' => {:additions => 2, :deletions => 2, :total => 4, :net => 0 } }
  } }

  it "should print authors reverse sorted by line count" do
    out = capture_stdout { GitRank::Printer.print(author_info) }
    out.should == <<-HEREDOC.gsub(/^      /, '')
      Rob Mattinson 7 (+4 -3)
      Matt Robinson 13 (+4 -9)
    HEREDOC
  end

  it "should print additions only if specified" do
    out = capture_stdout { GitRank::Printer.print(author_info, {:additions_only => true}) }
    out.should == <<-HEREDOC.gsub(/^      /, '')
      Rob Mattinson +4
      Matt Robinson +4
    HEREDOC
  end

  it "should print deletions only if specified" do
    out = capture_stdout { GitRank::Printer.print(author_info, {:deletions_only => true}) }
    out.should == <<-HEREDOC.gsub(/^      /, '')
      Rob Mattinson -3
      Matt Robinson -9
    HEREDOC
  end

  describe "when all_authors is specified" do
    it "should print authors and files breakdown" do
      out = capture_stdout { GitRank::Printer.print(author_info, :all_authors => true) }
      out.should == <<-HEREDOC.gsub(/^        /, '')
        Rob Mattinson 7 (+4 -3)
                      3 (+2 -1) foo
                      4 (+2 -2) bar
        Rob Mattinson 7 (+4 -3)
        Matt Robinson 13 (+4 -9)
                      1 (+1 -0) foo
                      2 (+0 -2) bar
                      10 (+3 -7) baz
        Matt Robinson 13 (+4 -9)
      HEREDOC
    end

    it "should print additions_only" do
      out = capture_stdout { GitRank::Printer.print(author_info, :all_authors => true, :additions_only => true) }
      out.should == <<-HEREDOC.gsub(/^        /, '')
        Rob Mattinson +4
                      +2 foo
                      +2 bar
        Rob Mattinson +4
        Matt Robinson +4
                      +1 foo
                      +0 bar
                      +3 baz
        Matt Robinson +4
      HEREDOC
    end

    it "should print deletions_only" do
      out = capture_stdout { GitRank::Printer.print(author_info, :all_authors => true, :deletions_only => true) }
      out.should == <<-HEREDOC.gsub(/^        /, '')
        Rob Mattinson -3
                      -1 foo
                      -2 bar
        Rob Mattinson -3
        Matt Robinson -9
                      -0 foo
                      -2 bar
                      -7 baz
        Matt Robinson -9
      HEREDOC
    end
  end

  it "should print with specified files excluded by regex" do
    out = capture_stdout do
      GitRank::Printer.print(
        author_info,
        :exfile => [ 'fo*', 'ba[xyz]' ],
        :all_authors => true
      )
    end
    out.should == <<-HEREDOC.gsub(/^      /, '')
      Matt Robinson 2 (+0 -2)
                    2 (+0 -2) bar
      Matt Robinson 2 (+0 -2)
      Rob Mattinson 4 (+2 -2)
                    4 (+2 -2) bar
      Rob Mattinson 4 (+2 -2)
    HEREDOC
  end
end
