module Minitest
  module Assertions
    def assert_num_queries(num, &block)
      before = ::Sequel::Rails::Railties::LogSubscriber.count
      res = yield
      after = ::Sequel::Rails::Railties::LogSubscriber.count

      case num
      when Range
        assert num.include?(after - before), "The number of database queries did not match expectations...\nExpected: #{num} (range)\n  Actual: #{after - before}"
      when Integer
        assert num == after - before, "The number of database queries did not match expectations...\nExpected: #{num}\n  Actual: #{after - before}"
      else
        raise ArgumentError, "Invalid argument passed to assert_num_queries: expected a Range or Integer value, but received #{num.inspect} instead."
      end

      res
    end

    def assert_no_queries(&block)
      assert_num_queries(0, &block)
    end
  end
end
