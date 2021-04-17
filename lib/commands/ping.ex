defmodule Commands.Ping do
  alias Nostrum.Api

  @spec ping(Nostrum.Struct.Message.t(), [String.t()]) :: {:ok, pid}
  def ping(msg, _args) do
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
  end
end
