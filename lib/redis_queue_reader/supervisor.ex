defmodule RedisQueueReader.Supervisor do
  use Supervisor

  def start_link(_params) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [])
    start_workers(sup, [])
    result
  end
  def start_workers(sup, _params) do
  	#start the subsupervisor for the redis sequence
  	result_sub = Supervisor.start_child( sup, supervisor(RedisQueueReader.SubSupervisor, [1]) )
  	result_sub
  end
  
  def init(_) do
    redis = Application.get_env(:redis_queue_reader, RedisQueueReader.Supervisor)
    pool_options = [
      name: {:local, :redis_pool},
      worker_module: RedisQueueReader.Redis,
      size:          redis[:redis_pool][:size],
      max_overflow:  redis[:redis_pool][:max_overflow]
    ]

    child_processes = [ :poolboy.child_spec(:redis_pool, pool_options, []), worker(RedisQueueReader.Manager, [1]) ]
  	supervise child_processes, strategy: :one_for_one
  end

end