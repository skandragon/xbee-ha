require 'rspec'
require 'spec_helper'

require 'retryable'

class FakeRetryable < Retryable
  def initialize(max_retries, timeout, &block)
    super(max_retries, timeout)
  end

  def do_retry
    notify(:retry_called)
  end

  def do_timeout
    notify(:timeout_called)
  end
end

describe Retryable do
  it "notifes" do
    tries = []
    retryable = Retryable.new(5, 10) { |status, args|
      tries << [ status, args ]
    }
    retryable.notify(:foo, :bar)
    retryable.notify(1, 2)
    expect(tries).to eq([[:foo, :bar], [1, 2]])
  end

  it "throws for unimplemented do_retry" do
    r = Retryable.new(5, 10) { |x| }
    expect { r.do_retry }.to raise_error(ArgumentError)
  end

  it "throws for unimplemented do_timeout" do
    r = Retryable.new(5, 10) { |x| }
    expect { r.do_timeout }.to raise_error(ArgumentError)
  end

  it "retries the right number of times" do
    tries = []
    r = FakeRetryable.new(2, 10) { |status, args|
      tries << [ status, args ]
    }
    now = Time.now + 11
    r.check_retry(now)
    expect(tries).to eq([[:retry_called, nil]])
    r.check_retry(now + 1)
    expect(tries).to eq([[:retry_called, nil]])
    now = now + 11
    r.check_retry(now)
    expect(tries).to eq([[:retry_called, nil], [:retry_called, nil]])
    now = now + 11
    r.check_retry(now)
    expect(tries).to eq([[:retry_called, nil], [:retry_called, nil], [:timeout_called, nil]])
  end
end

describe RetryableManager do
  it "retries and times out" do
    tries = []
    r = FakeRetryable.new(2, 10) { |status, args|
      tries << [ status, args ]
    }
    rm = RetryableManager.new(10)
    rm.add(r)

    4.times do |tick|
      rm.tick(Time.now + 11 * tick)
    end

    expect(tries).to eq([ [:retry_called, nil],
                          [:retry_called, nil],
                          [:timeout_called, nil]
                        ])
  end

  it "runs" do
    tries = []
    r = FakeRetryable.new(2, 1) { |status, args|
      tries << [ status, args ]
    }
    rm = RetryableManager.new(1)
    rm.add(r)
    rm.start

    sleep(2)
    rm.stop

    expect(tries).to_not be_empty
  end

  it "throws on double start" do
    rm = RetryableManager.new(10)
    rm.start
    expect { rm.start }.to raise_error(ArgumentError)
    rm.stop
    expect { rm.stop }.to raise_error(ArgumentError)
  end

  it "removes" do
    tries = []
    r = FakeRetryable.new(2, 1) { |status, args|
      tries << [ status, args ]
    }
    rm = RetryableManager.new(1)
    rm.add(r)
    expect(rm.entries.count).to eq(1)
    rm.remove(r)
    expect(rm.entries).to be_empty
  end
end
