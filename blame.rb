# myapp.rb
require 'sinatra'
require 'rugged'

class BlameApp < Sinatra::Base
  helpers do
    def convert_blame(blame)
      result = []
      blame.each do |hunk|
        lines_in_hunk = hunk[:lines_in_hunk]
        commit_id = hunk[:final_commit_id]
        (0...lines_in_hunk).each do |i|
          result.push(hunk)
        end
      end
      result
    end

    def commit_sha(repo, rev)
      if rev[-5..-1] == '-prev'
        commit = repo.lookup(rev[0...-5])
        return commit.parents[0].oid
      end
      rev
    end

    def abbrev(sha1)
      sha1[0...6]
    end
  end

  get '/blame/:rev/*' do |rev, file|
    repo_path = ENV['repo']
    repo = Rugged::Repository.new(repo_path)
    sha1 = commit_sha(repo, rev)
    if sha1 != rev
      redirect "/blame/#{abbrev(sha1)}/#{file}"
    end
    blob = repo.blob_at(sha1, file)
    blame = Rugged::Blame.new(repo, file, options = {:newest_commit => sha1})
    @blame = convert_blame(blame)
    @content = blob.content.split("\n")
    erb :blame
  end
end
