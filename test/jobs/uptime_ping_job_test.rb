require "test_helper"

class UptimePingJobTest < ActiveJob::TestCase
  test "uptime ping job executes without error" do
    # Mock the HTTP request to avoid actual network calls in tests
    Faraday.stubs(:get).returns(
      OpenStruct.new(success?: true, status: 200)
    )

    assert_nothing_raised do
      UptimePingJob.perform_now
    end
  end

  test "uptime ping job handles network errors gracefully" do
    # Mock a network error
    Faraday.stubs(:get).raises(StandardError.new("Network error"))

    # Should not raise an error
    assert_nothing_raised do
      UptimePingJob.perform_now
    end
  end

  test "uptime ping job can be enqueued" do
    assert_enqueued_jobs 1 do
      UptimePingJob.perform_later
    end
  end
end
