defmodule Utils.JudgeZero do
  import Nostrum.Struct.Embed
  alias Nostrum.Api

  @result_raw_url "https://judge0-ce.p.rapidapi.com/submissions/{token}?base64_encoded=true&fields=*"

  @spec get_elixir_lang_id :: 57
  def get_elixir_lang_id, do: 57

  @spec generate_auth_header(String.t()) :: [{String.t(), String.t()}]
  def generate_auth_header(host) do
    [
      { "content-type", "application/json" },
      { "x-rapidapi-key", Application.get_env(:sumi, :rapid_api_key) },
      { "x-rapidapi-host", host }
    ]
  end

  @spec get_timeout_options :: [{atom(), any()}]
  def get_timeout_options do
    [
      { :timeout, 15000 },
      { :recv_timeout, 15000 }
    ]
  end

  @spec get_eval_result(Nostrum.Struct.Message.t(), [{String.t(), String.t()}], String.t()) :: any()
  def get_eval_result(msg, header, token) do
    url = String.replace(@result_raw_url, "{token}", token)
    options = get_timeout_options()
    get_result(msg, url, header, options)
  end

  defp get_result(msg, url, header, options) do
    response = HTTPoison.get!(url, header, options)
    body = Jason.decode!(response.body)
    IO.puts("Status code: #{response.status_code}")
    if body["stderr"] != nil && body["stderr"] != "" do
      stderr = String.trim(body["stderr"]) |> String.replace("\n", "") |> Base.decode64!()
      error_msg = if body["message"] != nil && body["message"] != "" do
        message = String.trim(body["message"]) |> String.replace("\n", "") |> Base.decode64!()
        "ごめん。なんかおかしいことが発生した…兄さんなら何か知っているかも：#{stderr}\nあと、これは他のメッセージらしい：#{message}"
      else
        "ごめん。なんかおかしいことが発生した…兄さんなら何か知っているかも：#{stderr}"
      end
      error_msg = if String.length(error_msg) > 2000 do
        String.slice(error_msg, 0, 2000)
      else
        error_msg
      end
      Api.create_message(msg.channel_id, error_msg)
    else
      if body["stdout"] == nil || body["stdout"] == "" do
        if body["compile_output"] != nil && body["compile_output"] != "" do
          compile_output = if String.length(Base.decode64!(body["compile_output"])) > 2047 do
            decoded = String.trim(body["compile_output"])
            |> String.replace("\n", "")
            |> Base.decode64!()
            String.split_at(decoded, 2000)
            |> Tuple.to_list()
            |> Enum.at(0)
          else
            String.trim(body["compile_output"])
            |> String.replace("\n", "")
            |> Base.decode64!()
          end
          Api.create_message(msg.channel_id, "ごめん…兄さんがいなくて、俺の力だけではこのコードをコンパイルできないんだ：#{compile_output}")
        else
          Task.await(Task.async(fn ->
            :timer.sleep(:timer.seconds(2))
          end))
          get_result(msg, url, header, options)
        end
      else
        stdout = String.trim(body["stdout"])
        |> String.replace("\n", "")
        |> Base.decode64!()
        { member_name, member_icon } = Utils.Util.get_username_icon(msg.guild_id, msg.author.id)
        description = "やった！これは#{member_name}のコードの解釈結果だ！兄さんにも共有したいな！\n```bash\n#{stdout}\n```"
        description = if String.length(description) > 2000 do
          String.slice(description, 0, 2000)
        else
          description
        end
        embed = %Nostrum.Struct.Embed{}
        |> put_color(Utils.Util.get_sumi_color)
        |> put_description(description)
        |> put_thumbnail(Utils.Util.get_elixir_logo)
        |> put_author(member_name, "", member_icon)
        |> put_field("費やす時間", "#{body["time"]} 秒", true)
        |> put_field("メモリー", "#{body["memory"]} KB", true)
        embed = if body["exit_code"] != nil && body["exit_code"] != "" do
          put_field(embed, "エグジットコード", "#{body["exit_code"]}", true)
        else
          embed
        end
        embed = if body["exit_signal"] != nil && body["exit_signal"] != "" do
          put_field(embed, "エグジットシグナル", "#{body["exit_signal"]}", true)
        else
          embed
        end
        Api.create_message(msg.channel_id, embed: embed)
      end
    end
  end
end
