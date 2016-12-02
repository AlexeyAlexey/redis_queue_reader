defmodule RedisQueueReader.SubSupervisorReader do
  use Supervisor
  #use GenServer

  def start_link(name_of_queue, reader_functions) do
  	#{:ok, _pid} = Supervisor.start_link(__MODULE__, [])

  	result = Supervisor.start_link(__MODULE__, [name_of_queue, reader_functions], name: via_tuple(name_of_queue))
    
    result
  end

  #def start_new_parser(name_of_queue) do
  #  sup_pid = :gproc.where({ :n, :l, {:sub_supervisor_reader, name_of_queue} })
  #  if sup_pid == :undefined do
  #    IO.puts "Can not find queue named #{name_of_queue}"
  #  else
  #    Supervisor.start_child(sup_pid, [name_of_queue])
  #  end
  #end

  #def handle_call(:start_new_parser, _from, state) do
  #  {:state, {:via, :gproc, {:n, :l, {:sub_supervisor_reader, "queue_1"}
  #  pid = self()
  #  res = Supervisor.start_child(pid, [name_of_queue])

  #  {:reply, res, [name_of_queue] }
  #  {:reply, "res", state }
  #end

  def init(params) do
    child_processes = [ worker(RedisQueueReader.Reader, [params]) ]
  	supervise child_processes, strategy: :simple_one_for_one
  end

  defp via_tuple(name) do
    { :via, :gproc, {:n, :l, {:sub_supervisor_reader, name}} }    
  end
  
end