defmodule SumiApplication do
  use Application

  def start(_type, _args) do
    children = [Sumi]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

defmodule Sumi do
  @moduledoc """
  Documentation for `Sumi`.
  """
  @presences ["サッカー", "フライトチキンを食っている", "晴を探している", "寝ている", "勉強中"]
  @random_responses ["どうした、{user}？", "流石ですね、{user}！", "{user}、兄さんはどこか知っている？", "俺はいつも兄さんの後ろに兄さんに追いついてる。君も分かるだろう、{user}？", "{user}、おはよう。", "一緒にサッカーをやろうよ、{user}！", "フライトチキンを食いたくねぇの、{user}？"]
  @sumi_mention "806706183637041192"
  @commands %{
    ping: &Commands.Ping.ping/2,
    about: &Commands.About.about/2,
    owoify: &Commands.Owoify.owoify/2,
    eval: &Commands.Eval.eval/2
  }

  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def update_presence do
    Task.start fn ->
      :timer.sleep(:timer.hours(1))
      Api.update_status(:online, Enum.random(@presences))
      Task.start fn ->
        update_presence()
      end
    end
  end

  def handle_event({:READY, _map, _ws_state}) do
    HTTPoison.start()
    Task.start fn ->
      Api.update_status(:online, Enum.random(@presences), 0, nil)
      update_presence()
    end
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    author_mention = "<@!#{msg.author.id}>"
    if String.contains?(msg.content, @sumi_mention) do
      random_response = Enum.random(@random_responses)
      |> String.replace("{user}", author_mention)
      Api.create_message!(msg.channel_id, random_response)
    end

    prefix = Application.get_env(:sumi, :prefix)

    # Try splitting the content to determine the command to invoke.
    args = String.split_at(msg.content, String.length(prefix))
    |> Tuple.to_list()
    |> Enum.at(1)
    |> String.split(" ")
    command = Map.get(@commands, String.to_atom(Enum.at(args, 0)))
    actual_args = Enum.drop(args, 1)
    if command != nil do
      command.(msg, actual_args)
    else
      # Determine the command with prefix.
      first_arg = Enum.at(args, 0)
      cond do
        String.starts_with?(first_arg, "eval") ->
          Task.start(fn ->
            @commands[:eval].(msg, msg.content)
          end)
        true -> :ignore
      end
    end
  end

  def handle_event(_event) do
    :noop
  end
end
