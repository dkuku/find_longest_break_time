defmodule FreeTime do
  @moduledoc """
  Module finds longest break time from a list of ranges
  It uses pattern matching on string to parse input time ranges
  """
  @day_minutes 60 * 24

  @spec find_longest_free_break(list(String.t()), String.t()) :: String.t()
  def find_longest_free_break(list_of_ranges, start_of_day \\ "12:00PM") do
    start_of_day_minutes = get_time(start_of_day)

    list_of_ranges
    |> Enum.map(&parse_time_range_to_minutes(&1, start_of_day_minutes))
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
  @spec parse_time_range_to_minutes(String.t(), integer()) :: {integer(), integer()}
  defp parse_time_range_to_minutes(
         <<
           from::binary-size(7),
           ?-,
           to::binary-size(7)
         >>,
         start_of_day_minutes
       ) do
    from_time = get_time(from, start_of_day_minutes)
    to_time = get_time(to, start_of_day_minutes)
    {from_time, to_time}
  end

  defp parse_time_minutes(<<
         hours::binary-size(2),
         ?:,
         minutes::binary-size(2),
         am_or_pm::binary-size(2)
       >>) do
    {hours, minutes, am_or_pm}
  end

  @spec get_time(String.t(), integer()) :: integer()
  defp get_time(time, start_of_day_minutes \\ 0) do
    {hours, minutes, am_or_pm} = parse_time_minutes(time)
    total_minutes = get_minutes_from_hours(hours, am_or_pm) + get_minutes(minutes) - start_of_day_minutes

    cond do
      total_minutes < 0 ->
        total_minutes + @day_minutes

      true ->
        total_minutes
    end
  end

  @spec get_minutes_from_hours(String.t(), String.t()) :: integer()
  defp get_minutes_from_hours(hours, am_or_pm), do: 60 * get_hours(hours, am_or_pm)

  @spec get_hours(String.t(), String.t()) :: integer()
  defp get_hours(hours, "PM"), do: String.to_integer(hours) + 12
  defp get_hours(hours, _), do: String.to_integer(hours)
  @spec get_minutes(String.t()) :: integer()
  defp get_minutes(minutes), do: String.to_integer(minutes)
end
