defmodule Commands.About do
  import Nostrum.Struct.Embed
  alias Nostrum.Api

  @spec about(Nostrum.Struct.Message.t(), [String.t()]) :: {:ok, pid}
  def about(msg, _args) do
    Task.start fn ->
      description = "The Land of Cute Boisの澄。\n澄はマンガ・ビジュアルノベル「[記憶の怪物](https://store.steampowered.com/app/1430030/_/)」の主人公。\n澄バージョン0.4の開発者：\n**Tetsuki Syu#1250、Kirito#9286**\n実行環境：\n[Erlang/OTP 23](https://www.erlang.org/)、[Elixir 1.11.4](https://elixir-lang.org/)、[Nostrum](https://kraigie.github.io/nostrum/intro.html)ライブラリ。"
      embed = %Nostrum.Struct.Embed{}
      |> put_color(Utils.Util.get_sumi_color)
      |> put_description(description)
      |> put_thumbnail(Utils.Util.get_elixir_logo)
      |> put_author("記憶の怪物の澄", "", "https://cdn.discordapp.com/avatars/806706183637041192/e53034dfdfc40f778330ac55830f6da6.webp?size=1024")
      |> put_footer("澄ボット：リリース 0.4 | 2021-04-18")
      Api.create_message(msg.channel_id, embed: embed)
    end
  end
end
