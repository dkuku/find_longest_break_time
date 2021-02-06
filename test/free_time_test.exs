defmodule FreeTimeTest do
  use ExUnit.Case
  doctest FreeTime

  test "test parse list of ranges" do
    assert FreeTime.find_longest_free_break([
             "10:15AM-10:30AM",
             "11:15AM-11:30AM",
             "07:15AM-08:20AM",
             "10:15PM-10:30PM"
           ]) == "10:45"

    assert FreeTime.find_longest_free_break([
             "10:15AM-10:30AM",
             "11:15AM-11:30AM",
             "07:15AM-08:20AM"
           ]) == "01:55"
    assert FreeTime.find_longest_free_break([
             "00:15AM-00:30AM",
             "01:15AM-00:30AM",
           ]) == "00:45"
    assert FreeTime.find_longest_free_break([
             "23:15AM-23:30AM",
             "01:15AM-01:30AM",
           ], "02:00AM") == "01:45"
  end
end
