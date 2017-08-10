class PipeReader
  MB4 = 4 * 1024 * 1024
  MS10 = 0.01

  attr_reader :io_file

  def initialize(io_file)
    @io_file = io_file
  end

  # Yields output from file. Guaranteed to yield less than once every n ms
  def read(ms)
    read_at_time = now_f
    step = ms.to_f / 1000

    while true
      partial = read_all_blocking(io_file)
      break if not partial
      sleep(MS10) while now_f < read_at_time
      next_partial = read_all_non_blocking(io_file)
      partial += next_partial if next_partial
      read_at_time = now_f + step
      yield partial
    end
  end

  private
  def now_f
    DateTime.now.to_f
  end

  def read_all_blocking(io_file)
    io_file.readpartial(MB4)
  rescue EOFError
    nil
  end

  def read_all_non_blocking(io_file)
    partial = read_part_non_blocking(io_file)
    loop do
      next_partial = read_part_non_blocking(io_file)
      break unless next_partial
      partial += next_partial
    end
    partial
  end

  def read_part_non_blocking(io_file)
    io_file.read_nonblock(MB4)
  rescue IO::EAGAINWaitReadable
    nil
  rescue EOFError
    nil
  end
end
