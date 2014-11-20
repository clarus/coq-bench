# Check that packages are well-formed.

def puts_usage
  puts "Usage: ruby lint.rb repo folder"
  puts "  repo: stable or unstable"
  puts "  folder: the folder of a package"
end

def lint(repository, folder)
  name, version = File.basename(folder).split(".", 2)
  descr = File.read(File.join(folder, "descr"), encoding: "UTF-8")
  opam = File.read(File.join(folder, "opam"), encoding: "UTF-8")
  url = File.read(File.join(folder, "url"), encoding: "UTF-8")

  begin
    unless name.match(/\Acoq\:/) then
      raise "The package name should start with \"coq:\"."
    end
    unless name.match(/\A[a-z0-9:\-]+\z/) then
      raise "Wrong name #{name.inspect}, expected only small caps (a-z), digits (0-9), dashes or colons (-, :)."
    end
    unless descr.strip[-1] == "." then
      raise "The description should end by a dot (.) to ensure uniformity."
    end
    unless opam.match("%{jobs}%") then
      raise "The build script should use the `%{jobs}%` variable to speedup building time. For example:
build: [
  [make \"-j%{jobs}%\"]
  [make \"install\"]
]"
    end
    unless opam.match("homepage:") then
      raise "You should add an homepage for your package. For example:
homepage: \"https://github.com/user/project\""
    end
    unless opam.match("license:") then
      raise "You should specify the license to make your package public, if possible an open-source one. For example:
license: \"MIT\""
    end

    # Specific checkes for the stable repository.
    unless repository != "stable" then
      unless version.match(/\A[0-9]+\.[0-9]+\.[0-9]+\z/) then
        raise "Wrong stable version name #{version.inspect}, expected three numbers separated by dots."
      end
      unless url.match("checksum") then
        raise "A checksum is expected for the archive."
      end
    end

    puts "The package is valid."
  rescue Exception => e
    puts e
    exit(1)
  end
end

if ARGV.size == 2 then
  lint(*ARGV)
else
  puts_usage
  exit(1)
end