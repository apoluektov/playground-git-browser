# myapp.rb
require 'sinatra'
require 'rugged'
require 'rouge'
require 'json'

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
      if rev.nil?
        return repo.head.target.oid
      end

      Rugged::Object.rev_parse_oid(repo, rev)
    end

    def abbrev(sha1)
      sha1[0...6]
    end
  end

  get '/commitHeader/:sha1' do |rev|
    repo_path = ENV['repo']
    repo = Rugged::Repository.new(repo_path)
    sha1 = commit_sha(repo, rev)
    commit = repo.lookup(sha1)
    { :date => commit.author[:time], :author => commit.author[:name], :message => commit.message }.to_json
  end

  get '/blame/*' do |file|
    rev = params['rev']

    repo_path = ENV['repo']
    repo = Rugged::Repository.new(repo_path)
    sha1 = abbrev(commit_sha(repo, rev))
    if sha1 != abbrev(rev)
      redirect "/blame/#{file}?rev=#{sha1}"
    end

    @commit = repo.lookup(sha1)

    blob = repo.blob_at(sha1, file)
    blame = Rugged::Blame.new(repo, file, options = {:newest_commit => sha1})
    @blame = convert_blame(blame)

    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexer::guess(info = {:filename => file})
    highlighted = formatter.format(lexer.lex(blob.content))
    @content = highlighted.split("\n")
    erb :blame
  end
end
