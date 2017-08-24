class RunShell
  attr_reader :env, :cmd, :args

  def initialize(env, cmd, *args)
    @env = env
    @cmd = cmd
    @args = args
    @read_input, @write_input = IO.pipe
    @read_output, @write_output = IO.pipe
  end

  def stdin
    @write_input
  end

  def execute!
    # Run the child process in separate thread so that we can close write
    thread = Thread.new do
      pid_result = system(@env, @cmd, *@args, :in => @read_input, :out => @write_output, :err => [:child, :out])
      @write_output.close
      @read_input.close
      {success: pid_result}
    end

    PipeReader.new(@read_output).read(100) { |o| yield o}

    thread.value
  ensure
    [@read_input, @write_input, @read_output, @write_output].each(&:close)
  end

  def self.execute!(env, cmd, *args)
    shell = new(env, cmd, *args)
    shell.stdin.close
    shell.execute! { |o| yield o }
  end
end
