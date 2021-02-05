defmodule FreeTime do
  @moduledoc """
  Module finds longest break time from a list of ranges
  It uses pattern matching on string to parse input time ranges
  """

  @spec find_longest_free_break(list(String.t())) :: String.t()
  def find_longest_free_break(list_of_ranges) do
    list_of_ranges
    |> Enum.map(&parse_time_range_to_minutes(&1))
    |> Enum.sort()
    |> Enum.reduce({0, 0}, &break_time_reducer/2)
    |> extract_max_time()
    |> convert_minutes_to_hh_mm()
  end

  @spec break_time_reducer({integer(), integer()}, {integer(), integer()}) ::
          {integer(), integer()}
  defp break_time_reducer({_first_entry_from, first_entry_to}, {0, 0}) do
    {0, first_entry_to}
  end

  defp break_time_reducer(
         {entry_from, entry_to},
         {max_recorded_time, previous_entry_to}
       ) do
    current_break_time = entry_from - previous_entry_to

    cond do
      current_break_time > max_recorded_time -> {current_break_time, entry_to}
      true -> {max_recorded_time, entry_to}
    end
  end

  @spec extract_max_time({integer(), integer()}) :: integer()
  defp extract_max_time({max_time, _}), do: max_time

  @spec convert_minutes_to_hh_mm(integer()) :: String.t()
  defp convert_minutes_to_hh_mm(total_minutes) do
    minutes = rem(total_minutes, 60)
    hours = trunc(total_minutes / 60)
    format_two_integers(hours) <> ":" <> format_two_integers(minutes)
  end

  @spec format_two_integers(integer()) :: String.t()
  defp format_two_integers(number) do
    number
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

  #  assert FreeTime.parse_time_range_to_minutes("10:15AM-10:30PM") == {615, 1350}
  @spec parse_time_range_to_minutes(String.t()) :: {integer(), integer()}
  defp parse_time_range_to_minutes(<<
         hours_from::binary-size(2),
         ?:,
         minutes_from::binary-size(2),
         am_or_pm_from::binary-size(2),
         ?-,
         hours_to::binary-size(2),
         ?:,
         minutes_to::binary-size(2),
         am_or_pm_to::binary-size(2)
       >>) do
    from_time = get_time(hours_from, minutes_from, am_or_pm_from)
    to_time = get_time(hours_to, minutes_to, am_or_pm_to)
    {from_time, to_time}
  end

  @spec get_time(String.t(), String.t(), String.t()) :: integer()
  defp get_time(hours, minutes, am_or_pm) do
    get_minutes_from_hours(hours, am_or_pm) + get_minutes(minutes)
  end

  @spec get_minutes_from_hours(String.t(), String.t()) :: integer()
  defp get_minutes_from_hours(hours, am_or_pm), do: 60 * get_hours(hours, am_or_pm)

  @spec get_hours(String.t(), String.t()) :: integer()
  defp get_hours(hours, "PM"), do: String.to_integer(hours) + 12
  defp get_hours(hours, _), do: String.to_integer(hours)
  @spec get_minutes(String.t()) :: integer()
  defp get_minutes(minutes), do: String.to_integer(minutes)
end
