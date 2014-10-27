# Handle interactions with OPAM.
require_relative 'package'

module Opam
  # The list of all Coq packages in the given repositories.
  def Opam.all_packages(repositories)
    repositories.map do |repository|
      Dir.glob("../#{repository}/packages/*/*").map do |path|
        name, version = File.basename(path).split(".", 2)
        Package.new(name, version)
      end
    end.flatten(1).sort {|x, y| x.to_s <=> y.to_s}
  end

  # Add a repository.
  def Opam.add_repository(repository)
    system("opam", "repo", "add", "--root=.opam", "--kind=git", repository, "../#{repository}")
  end
end