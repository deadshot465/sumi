import Nostrum.Struct.Embed

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
  @sumi_mention "<@!806706183637041192>"

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

    case msg.content do
      "s?ping" ->
        start_time = Time.utc_now(Calendar.ISO)
        task = Task.async fn ->
          Api.create_message!(msg.channel_id, "🏓 ピング中……")
        end
        message = Task.await(task)
        end_time = Time.utc_now(Calendar.ISO)
        difference = Time.diff(end_time, start_time, :millisecond)
        Task.start fn ->
          Api.edit_message(message, content: "🏓 ポン！\nレイテンシ：#{difference}ミリ秒。")
        end
      "s?about" ->
        Task.start fn ->
          description = "The Land of Cute Boisの澄。\n澄はマンガ・ビジュアルノベル「[記憶の怪物](https://store.steampowered.com/app/1430030/_/)」の主人公。\n澄バージョン0.1の開発者：\n**Tetsuki Syu#1250、Kirito#9286**\n実行環境：\n[Erlang/OTP 23](https://www.erlang.org/)、[Elixir 1.11.3](https://elixir-lang.org/)、[Nostrum](https://kraigie.github.io/nostrum/intro.html)ライブラリ。"
          embed = %Nostrum.Struct.Embed{}
          |> put_color(0x585987)
          |> put_description(description)
          |> put_thumbnail("https://cdn.discordapp.com/emojis/291709559477895169.png")
          |> put_author("記憶の怪物の澄", "", "https://cdn.discordapp.com/avatars/806706183637041192/e53034dfdfc40f778330ac55830f6da6.webp?size=1024")
          |> put_footer("澄ボット：リリース 0.3 | 2021-03-26")
          Api.create_message(msg.channel_id, embed: embed)
        end
      _ ->
        :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end
end
