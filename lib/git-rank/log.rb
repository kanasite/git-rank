module GitRank
module Log
  class << self
    def calculate(options = {})
      authors = Hash.new {|h, k| h[k] = h[k] = Hash.new(0)}
      options_digest = Digest::MD5.hexdigest(options[:additions_only].to_s + options[:deletions_only].to_s)

      author = nil
      file = nil
      state = :pre_author
      git_log.each do |line|
        case
        when (state == :pre_author || state == :post_author) && line =~ /Author: (.*)\s</
          author = $1
          state = :post_author
        when line =~ /^(\d+)\s+(\d+)\s+(.*)/
          additions = $1.to_i
          deletions = $2.to_i
          file = $3
          authors[author][file] += (additions + deletions)
          state = :in_diff
        when state == :in_diff && line =~ /^commit /
          state = :pre_author
        end
      end
      authors
    end

    private

    def git_log
      `git log -M -C -C -w --no-color --numstat`
    end
  end
end
end
