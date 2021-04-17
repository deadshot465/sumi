defmodule Commands.Eval do
  @submission_url "https://judge0-ce.p.rapidapi.com/submissions?base64_encoded=true&fields=*"

  @spec eval(Nostrum.Struct.Message.t(), String.t()) :: {:ok, pid}
  def eval(msg, content) do
    command = "s?eval\n"
    code = String.split_at(content, String.length(command))
    |> Tuple.to_list()
    |> Enum.at(1)
    |> String.split("\n")
    |> Enum.drop(1)
    |> (fn enum ->
      List.delete_at(enum, Enum.count(enum) - 1)
    end).()
    |> Enum.join("\n")

    header = Utils.RapidAPI.generate_auth_header("judge0-ce.p.rapidapi.com")
    request_data = Jason.encode!(%{
      language_id: Utils.RapidAPI.get_elixir_lang_id(),
      source_code: Base.encode64(code)
    })
    response = HTTPoison.post!(@submission_url, request_data, header, Utils.RapidAPI.get_timeout_options())
    IO.puts("Status code: #{response.status_code}")
    body = Jason.decode!(response.body)
    Task.start(fn ->
      Utils.RapidAPI.get_eval_result(msg, header, body["token"])
    end)
  end
end
