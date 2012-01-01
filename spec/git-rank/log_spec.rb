#!/usr/bin/env rspec

require 'spec_helper'
require 'git-rank/log'

describe GitRank::Log do
  let (:log_output) do <<-HEREDOC.gsub(/      /, '')
      commit da9ef7ea662df1073e8b292e278c95c8ce7cfc7f
      Author: Matt Robinson <matt@puppetlabs.com>
      Date:   Sat Dec 31 00:11:30 2011 -0800

          Second commit

      0       3       bar
      6       2       foo

      commit 5047abc2a5cb09eb16abe6a4107b28e63cb57e59
      Author: Matt Robinson <matt@puppetlabs.com>
      Date:   Sat Dec 31 00:10:06 2011 -0800

          Initial Commit

      5       0       bar
      5       0       foo
    HEREDOC
  end

  describe "when calculating rank" do
    it "should get correct line counts" do
      GitRank::Log.expects(:git_log).returns(log_output)

      authors = GitRank::Log.calculate
      authors.should == { "Matt Robinson"=> { 'foo' => 13, "bar" => 8 } }
    end
  end
end
