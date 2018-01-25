defmodule Huffman do
  def sample do
    'the quick brown fox jumps over the lazy dog
    this is a sample text that we will use when we build
    up a table we will only handle lower case letters and
    no punctuation symbols the frequency will of course not
    represent english but it is probably not that far off'
    end

  def text, do: 'this is something that we should encode'

  def test do
    sample = sample()
    tree = tree(sample)
    encode = encode_table(tree)
    decode = decode_table(tree)
    text = text()
    seq = encode(text, encode)
    IO.inspect(sample)
    IO.inspect(tree)
    IO.inspect(encode)
    IO.inspect(decode)
    IO.inspect(text)
    IO.inspect(seq)
    decode(seq, decode)
  end

  def testKallocain(numberOfChars) do
    msg = read('kallocain.txt', numberOfChars)
    {tree, t1} = time(fn -> tree(msg) end)
    {encode, t2} = time(fn -> encode_table(tree) end)
    {decode, t3} = time(fn -> decode_table(tree) end)
    text = msg
    {seq, t4} = time(fn -> encode(text, encode) end)
    #IO.inspect(sample)
    #IO.inspect(tree)
    #IO.inspect(encode)
    #IO.inspect(decode)
    #IO.inspect(text)
    #IO.inspect(seq)
    #to_string(decode(seq, decode))
    {_, t5} = time(fn -> decode(seq, decode) end)
    IO.inspect("tree #{t1}")
    IO.inspect("encodeTable #{t2}")
    IO.inspect(t3)
    IO.inspect("encode #{t4}")
    IO.inspect("decode #{t5}")
    t1+t2+t3+t4+t5
  end

  def tree(sample) do
    freq = freq(sample)
    huffman(freq)
  end

  def freq(sample) do freq(sample, []) end
  def freq([], freq) do freq end
  def freq([char | rest], freq) do
    freq(rest, updateFreq(char, freq))
  end

  def updateFreq(char, []) do [{char, 1}] end
  def updateFreq(char, [{char, n}|restFreq]) do
    [{char, n + 1} | restFreq]
  end
  def updateFreq(char, [otherChar|restFreq]) do
    [otherChar | updateFreq(char, restFreq)]
  end

  def huffman(freq) do
    sorted = Enum.sort(freq, fn({_, x}, {_, y}) -> x < y end)
    huffman_tree(sorted)
  end

  def huffman_tree([{tree, _}]), do: tree
  def huffman_tree([{a, aFreq}, {b, bFreq}|rest]) do
    huffman_tree(insert({{a, b}, aFreq + bFreq}, rest))
  end

  def insert({a, aFreq}, []), do: [{a, aFreq}]
  def insert({a, aFreq}, [{b, bFreq} | rest]) when aFreq < bFreq do
    [{a, aFreq}, {b, bFreq} | rest]
  end
  def insert({a, aFreq}, [{b, bFreq} | rest]) do
    [{b, bFreq} | insert({a, aFreq}, rest)]
  end

  def encode_table(tree) do
    search(tree, [], [])
  end

  def search({a, b}, soFarSoGood, acc) do
    left = search(a, [0 | soFarSoGood], acc)
    search(b, [1 | soFarSoGood], left)
  end
  def search(a, binaryCode, acc) do
    [{a, Enum.reverse(binaryCode)} | acc]
  end

  def encode([], _), do: []
  def encode([char | rest], table) do
    {_, binaryCode} = List.keyfind(table, char, 0)
    binaryCode ++ encode(rest, table)
  end

  def decode_table(tree) do
    search(tree, [], [])
  end

  def decode([], _), do: []
  def decode(seq, table) do
    {char, rest} = decode_char(seq, 1, table)
    [char | decode(rest, table)]
  end

  def decode_char(seq, n, table) do
    {code, rest} = Enum.split(seq, n)

    case List.keyfind(table, code, 1) do
      {char, _} ->
        {char, rest}
      nil ->
        decode_char(seq, n+1, table)
    end
  end

  def read(file, n) do
    {:ok, file} = File.open(file, [:read])
    binary = IO.read(file, n)
    File.close(file)
    case :unicode.characters_to_list(binary, :utf8) do
      {:incomplete, list, _} ->
        list;
      list ->
        list
    end
  end

  def time(func) do
    initial = Time.utc_now()
    result = func.()
    final = Time.utc_now()
    {result, Time.diff(final, initial, :microsecond) / 1000000}
  end

end
