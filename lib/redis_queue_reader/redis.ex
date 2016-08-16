defmodule RedisQueueReader.Redis do
  use GenServer

  
  ####
  #External API

  def start_link(_params) do
    {:ok, redis_client_pid} = Exredis.start_link( Application.get_env(:redis_queue_reader, RedisQueueReader.Redis) )

  	GenServer.start_link(__MODULE__, {redis_client_pid})
  end

 
  
  #####
  # GenServer implementation

  def init(redis_client_pid) do
  	{:ok, redis_client_pid}
  end

  def handle_call({:read_from_queue, queue_named}, _from, {redis_client_pid}) do
  	
    resp = Exredis.query redis_client_pid, ["RPOP", queue_named]

  	{ :reply, resp, {redis_client_pid} }
  end

  def terminate(_reason, {redis_client_pid}) do
    
    redis_client_pid |> Exredis.stop

    :ok
  end

end