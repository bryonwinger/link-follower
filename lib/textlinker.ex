defmodule TextLinker do
  @moduledoc """
  Documentation for TextLinker.
  """

  @doc """
  Hello world.

  ## Examples

      iex> TextLinker.hello
      :world

  """

  def main(args) do
    args |> parse_args |> process
  end

  def process([]) do
    IO.puts "You need to pass a url!"
    exit 1
  end

  def process(url) do
    TextLinker.Processor.get(url)
  end

  defp parse_args(args) do
    {_, args, _} = OptionParser.parse(args,
      switches: []
    )
    args
  end
end
