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

  def get_url(url) do
    HTTPoison.start
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts "(200)"
        process_response(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "(404) Not found: #{url}"
        nil
      {:ok, %HTTPoison.Response{status_code: 301, body: body}} ->
        follow_redirect(body)
      {:ok, %HTTPoison.Response{status_code: 302, body: body}} ->
        follow_redirect(body)
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        nil
    end
  end

  def process_response(body) do
    Floki.parse(body)
  end

  def follow_redirect(body) do
    next_url = body
    |> find_links()
    |> hd()

    IO.puts "(301) Redirect, following to #{next_url}"
    get_url(next_url)
  end

  def find_links(body) do
    body
    |> Floki.find("a")
    |> Floki.attribute("href")
  end

  def load_url(url) do
    body = get_url(url)
    |> find_links()
    |> selection_input()
  end

  def selection_input(links) do
    links
    |> Enum.with_index
    |> Enum.each(fn({link, i}) ->
      IO.puts("#{i + 1}:  #{link}")
    end)
    
    choice = IO.gets("Choose a link to follow: ")
    |> String.trim
    |> String.to_integer

    next_link = Enum.at(links, choice - 1)
    IO.puts "you chose " <> next_link

    load_url(next_link)
  end
end
