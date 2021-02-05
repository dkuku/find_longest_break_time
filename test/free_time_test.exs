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
  end
end
