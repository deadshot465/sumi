defmodule Utils.Util do
  alias Nostrum.Api

  @spec get_sumi_color :: 5_790_087
  def get_sumi_color, do: 0x585987

  @spec get_elixir_logo :: String.t()
  def get_elixir_logo, do: "https://cdn.discordapp.com/emojis/291709559477895169.png"

  @spec get_user_avatar_url(Nostrum.Snowflake.t(), String.t()) :: String.t()
  def get_user_avatar_url(user_id, hash) do
    "https://cdn.discordapp.com/avatars/#{user_id}/#{hash}.png"
  end

  @spec get_username_icon(Nostrum.Snowflake.t(), Nostrum.Snowflake.t()) :: {String.t(), String.t()}
  def get_username_icon(guild_id, user_id) do
    member = Api.get_guild_member!(guild_id, user_id)
    if member.nick == nil do
      { member.user.username, get_user_avatar_url(member.user.id, member.user.avatar) }
    else
      { member.nick, get_user_avatar_url(member.user.id, member.user.avatar) }
    end
  end
end
