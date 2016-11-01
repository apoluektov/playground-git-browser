# myapp.rb
require 'sinatra'
require 'rugged'

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
end

get '/blame/:rev/*' do |rev, file|
  repo_path = ARGV[0]
  repo = Rugged::Repository.new(repo_path)
  blob = repo.blob_at(rev, file)
  blame = Rugged::Blame.new(repo, file, options = {:newest_commit => rev})
  @blame = convert_blame(blame)
  @content = blob.content.split("\n")
  erb :blame
end
