defmodule RedisQueueReader.SubSupervisor do
  use Supervisor

  def start_link(_) do
  	result = Supervisor.start_link(__MODULE__, [], name: :sub_supervisor_readers)
     
    result
  end

  def init(params) do
    child_processes = [ worker(RedisQueueReader.SubSupervisorReader, []) ]

  	supervise child_processes, strategy: :simple_one_for_one
  end
 
end