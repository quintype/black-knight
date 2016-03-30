require 'rubygems/package'

class Tarball
  def initialize(files_json)
    @files_json = files_json
  end

  def to_s
    str = StringIO.new
    Gem::Package::TarWriter.new(str) do |tar|
      @files_json.each_pair do |key, value|
        tar.add_file_simple(key, 0644, value.length) { |io| io.write value }
      end
    end
    str.string
  end
end
