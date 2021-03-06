defmodule Servy.PledgeServer do

  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [ {name, amount} | most_recent_pledges ]
        send sender, {:response, id}
        listen_loop(new_state)
      {sender, :recent_pledges} ->
        send sender, {:response, state}
        listen_loop(state)
    end
  end

  def create_pledge(pid, name, amount) do
    send pid, {self(), :create_pledge, name, amount}

    receive do {:response, status} -> status end
  end

  def recent_pledges(pid) do
    send pid, {self(), :receive_pledges}

    receive do {:response, pledges} -> pledges end
  end

  defp send_pledge_to_service(_name, _amount) do
    #CODE HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

end

alias Servy.PledgeServer

pid = spawn(PledgeServer, :listen_loop, [[]])

IO.inspect PledgeServer.create_pledge(pid, "larry", 10)
IO.inspect PledgeServer.create_pledge(pid, "moe", 20)
IO.inspect PledgeServer.create_pledge(pid, "curly", 30)
IO.inspect PledgeServer.create_pledge(pid, "daisy", 40)
IO.inspect PledgeServer.create_pledge(pid, "grace", 50)

IO.inspect PledgeServer.recent_pledges(pid)
