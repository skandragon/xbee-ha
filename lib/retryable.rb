require 'time'

class Retryable
  attr_reader :retry_time, :timeout, :retries_remaining, :terminal

  def initialize(max_retries, timeout, &block)
    @timeout = timeout
    @retry_time = Time.now + timeout
    @retries_remaining = max_retries
    @block = block
    @terminal = false
  end

  def notify(*args)
    @block.call(*args)
  end

  def check_retry(now)
    if !terminal && retry_time < now
      attempt_retry(now)
    end
  end

  def attempt_retry(now)
    if retries_remaining > 0
      @retries_remaining -= 1
      @retry_time = now + timeout
      do_retry
    else
      @terminal = true
      do_timeout
    end
  end

  def do_retry
    raise ArgumentError.new("retry not implemented")
  end

  def do_timeout
    raise ArgumentError.new("timeout not implemented")
  end
end

class RetryableManager
  attr_reader :entries, :timeout_interval

  def initialize(timeout_interval = 10)
    @entries = []
    @thread = nil
    @timeout_interval = timeout_interval
    @mutex = Mutex.new
  end

  def start
    @mutex.synchronize {
      raise ArgumentError.new("RetryableManager already started") if @thread
      @thread = Thread.new { run }
    }
  end

  def stop
    @mutex.synchronize {
      raise ArgumentError.new("RetryableManager not started") unless @thread
      @thread.kill
      @thread.join
      @thread = nil
    }
  end

  def tick(now)
    @mutex.synchronize {
      @entries.each do |entry|
        entry.check_retry(now)
      end
    }
  end

  def run
    loop do
      sleep(timeout_interval)
      tick(Time.now)
    end
  end

  def add(entry)
    @mutex.synchronize {
      @entries << entry
    }
  end

  def remove(entry)
    @mutex.synchronize {
      @entries.delete(entry)
    }
  end
end
