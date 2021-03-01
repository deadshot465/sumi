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
  @presences ["Soccer", "Eating fried chicken", "Finding Haru", "Sleeping", "Studying"]

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
    case msg.content do
      "s?ping" ->
        start_time = Time.utc_now(Calendar.ISO)
        task = Task.async fn ->
          Api.create_message!(msg.channel_id, "🏓 Pinging...")
        end
        message = Task.await(task)
        end_time = Time.utc_now(Calendar.ISO)
        difference = Time.diff(end_time, start_time, :millisecond)
        Task.start fn ->
          Api.edit_message(message, content: "🏓 Pong!\nLatency is: #{difference}ms.")
        end
      "s?about" ->
        Task.start fn ->
          description = "Sumi in the Church of Minamoto Kou.\nSumi was inspired by the manga/visual novel/novel The Monster of Memory.\nSumi version 0.1 was made and developed by:\n**Tetsuki Syu#1250, Kirito#9286**\nRuntime environment:\nErlang/OTP 23, Elixir 1.11.3"
          embed = %Nostrum.Struct.Embed{}
          |> put_color(0x585987)
          |> put_description(description)
          |> put_thumbnail("https://cdn.discordapp.com/emojis/291709559477895169.png")
          |> put_author("Sumi from The Monster of Memory", "", "https://cdn.discordapp.com/avatars/806706183637041192/e53034dfdfc40f778330ac55830f6da6.webp?size=1024")
          |> put_footer("Sumi Bot: Release 0.2 | 2021-03-01")
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
