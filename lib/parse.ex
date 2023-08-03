defmodule Isomm.ParseMessage do
  alias ElixirISO8583.Parse

  # encoding_scheme must be either :bin or :ascii
  # tpdu_size and mti_size must be the total TPDU character
  # iso_spec must be a list of 4 elements tuples {bit_position, header_size, data_type, maximum_size}
  # for example:
  #
  # iso_spec = [
  #   {2, 2, :num, 19},
  #   {3, 0, :num, 6},
  #   {4, 0, :num, 12},
  #   {7, 0, :num, 10},
  #   {11, 0, :num, 6},
  #   {12, 0, :num, 6},
  #   {13, 0, :num, 4},
  #   {14, 0, :num, 4},
  #   {15, 0, :num, 4},
  #   {17, 0, :num, 4},
  #   {18, 0, :num, 4},
  #   {22, 0, :num, 3},
  #   {23, 0, :num, 3},
  #   {25, 0, :num, 2},
  #   {27, 0, :num, 1},
  #   {30, 0, :num, 9},
  #   {32, 2, :num, 11},
  #   {35, 2, :num, 37},
  #   {37, 0, :num, 12},
  #   {38, 0, :num, 6},
  #   {39, 0, :num, 2},
  #   {41, 0, :alphanum, 16},
  #   {42, 0, :alphanum, 15},
  #   {43, 0, :alphanum, 40},
  #   {48, 3, :alphanum, 30},
  #   {49, 0, :alphanum, 3},
  #   {50, 0, :alphanum, 3},
  #   {52, 0, :alphanum, 16},
  #   {53, 0, :alphanum, 16},
  #   {54, 3, :alphanum, 12},
  #   {55, 3, :br, 999},
  #   {60, 0, :alphanum, 19},
  #   {61, 0, :alphanum, 22},
  #   {64, 0, :alphanum, 16},
  #   {66, 0, :alphanum, 1},
  #   {70, 0, :alphanum, 3},
  #   {74, 0, :alphanum, 10},
  #   {75, 0, :alphanum, 10},
  #   {76, 0, :alphanum, 10},
  #   {77, 0, :alphanum, 10},
  #   {80, 0, :alphanum, 10},
  #   {81, 0, :alphanum, 10},
  #   {86, 0, :alphanum, 16},
  #   {87, 0, :alphanum, 16},
  #   {88, 0, :alphanum, 16},
  #   {89, 0, :alphanum, 16},
  #   {90, 0, :alphanum, 42},
  #   {97, 0, :alphanum, 17},
  #   {99, 2, :alphanum, 11},
  #   {100, 2, :alphanum, 11},
  #   {120, 0, :alphanum, 9},
  #   {123, 3, :alphanum, 153},
  #   {125, 0, :alphanum, 15},
  #   {128, 0, :alphanum, 16}
  # ]
  #
  # mapper must be a function have one struct parameter, that struct have key value that contains mti and proc code combination that maps to an integer (that will map later to txn type)
  # for example:
  # sample_mapper = fn (iso_msg) ->
  #   case iso_msg do
  #     %{:mti => "0200", 3 => "00" <> _} -> 1
  #     %{:mti => "0200", 3 => "02" <> _} -> 2
  #     %{:mti => "0200", 3 => _} -> 0
  #     %{:mti => "0400", 3 => "00" <> _} -> 3
  #     %{:mti => "0400", 3 => "02" <> _} -> 4
  #     %{:mti => "0400", 3 => "93" <> _} -> 6
  #     %{:mti => "0400", 3 => _} -> 0
  #     %{:mti => "0500", 3 => "93" <> _} -> 5
  #     %{:mti => "0500", 3 => "94" <> _} -> 4
  #     %{:mti => "0500", 3 => "92" <> _} -> 7
  #     %{:mti => "0500", 3 => "96" <> _} -> 8
  #     %{:mti => "0500", 3 => _} -> 0
  #     %{:mti => "0800", 3 => "93" <> _} -> 11
  #     %{:mti => "0800", 3 => "94" <> _} -> 12
  #     %{:mti => "0800", 3 => _} -> 0
  #     %{:mti => "0320", 3 => <<_::binary-size(5), "0">>} -> 9
  #     %{:mti => "0320", 3 => <<_::binary-size(5), "1">>} -> 10
  #   end
  # end


  def parse(raw_message, encoding_scheme, tpdu_size, mti_size, iso_spec, mapper) do

    {tpdu, raw_message} = parse_tpdu(raw_message, encoding_scheme, tpdu_size)
    {mti, body} = parse_mti(raw_message, encoding_scheme, mti_size)

    parsed_msg = Parse.parse_msg(body, encoding_scheme, iso_spec)
    |> Map.put(:mti, mti)

    txn_type = mapper.(parsed_msg)
    %Isomm.Message{msg_type: txn_type, msg_body: parsed_msg}

  end

  def parse_tpdu(raw_message, :ascii, size) do
    <<tpdu::binary-size(size), rest::binary>> = raw_message
    {tpdu, rest}
  end

  def parse_tpdu(raw_message, :bin, size) do
    <<tpdu::binary-size(div(size, 2)), rest::binary>> = raw_message
    {Base.encode16(tpdu), rest}
  end

  def parse_mti(raw_message, :ascii, size) do
    <<mti::binary-size(size), rest::binary>> = raw_message
    {mti, rest}
  end

  def parse_mti(raw_message, :bin, size) do
    <<mti::binary-size(div(size, 2)), rest::binary>> = raw_message
    {Base.encode16(mti), rest}
  end

end
