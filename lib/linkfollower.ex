defmodule LinkFollower do
  @moduledoc """
  Documentation for LinkFollower.
  """

  @doc """
  A simple program for following HTML links (<a> tags) at the command line. Not
  intended to actually do anything useful.

  ## Examples

      ./linkfollower http://google.com
      ...

  """

  def main(args) do
    args |> parse_args |> process
  end

  def process([]) do
    IO.puts "You need to pass a url!"
    exit 1
  end

  def process(url) do
    LinkFollower.Processor.get(url)
  end

  defp parse_args(args) do
    {_, args, _} = OptionParser.parse(args,
      switches: []
    )
    args
  end
end
