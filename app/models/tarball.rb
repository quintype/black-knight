require 'rubygems/package'

class Tarball
  def initialize(files_json)
    @files_json = files_json
  end

  def write_to_io(output)
    Gem::Package::TarWriter.new(output) do |tar|
      @files_json.each_pair do |key, value|
        tar.add_file_simple(key, 0644, value.length) { |io| io.write value }
      end
    end
  end

  def to_s
    str = StringIO.new
    write_to_io(str)
    str.string
  end
end
