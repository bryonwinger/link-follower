defmodule TextLinker.Processor do
  @moduledoc """
  Documentation for TextLinker.
  """

  @doc """
  Hello world.

  ## Examples

      iex> TextLinker.hello
      :world

  """

  def get(url) do
    IO.puts "fetching #{url}"
    links = fetch_body(url)
    |> find_links()

    print_links(links)
    get_user_input(links, url)
  end

  def fetch_body(url) do
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

  defp process_response(body) do
    Floki.parse(body)
  end

  defp follow_redirect(body) do
    next_url = body
    |> find_links()
    |> hd()

    IO.puts "redirect, following to #{next_url}"
    fetch_body(next_url)
  end

  defp find_links(body) do
    body
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(&(!String.starts_with?(&1, "#")))
    |> Enum.filter(&("" != &1))
    |> Enum.uniq
  end

  defp print_links(links) do
    links
    |> Enum.with_index
    |> Enum.each(fn({link, i}) ->
      IO.puts("#{i + 1}:  #{link}")
    end)
  end

  defp assemble_full_url(link, current_url) do
    link = Regex.run(~r{(\w|\d|_|-)+.+[^/]}, link)
    |> Enum.at(0)

    cond do
      String.starts_with?(link, "http") ->
        link
      String.starts_with?(link, "www.") ->
        "http://#{link}"
      true ->
        "#{current_url}/#{link}"
    end
  end

  defp get_user_input(links, current_url) do  
    choice = IO.gets("Choose a link to follow (ctrl+c to exit): ")
    |> String.trim
    |> String.to_integer

    next_link = Enum.at(links, choice - 1)
    IO.puts "you chose " <> next_link

    assemble_full_url(next_link, current_url)
    |>  get
  end
end
