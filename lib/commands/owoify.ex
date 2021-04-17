defmodule Commands.Owoify do
  alias Nostrum.Api

  def owoify(msg, args) do
    first_arg = Enum.at(args, 0) |> String.downcase()
    level = case first_arg do
      "soft" -> "owo"
      "medium" -> "uwu"
      "hard" -> "uvu"
      _ -> "owo"
    end
    text = if first_arg != "soft" && first_arg != "medium" && first_arg != "hard" do
      Enum.join(args, " ")
    else
      Enum.drop(args, 1) |> Enum.join(" ")
    end
    Api.create_message(msg.channel_id, content: OwoifyEx.owoify(text, level))
  end
end
