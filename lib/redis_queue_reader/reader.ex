defmodule RedisQueueReader.Reader do
  use GenServer
  
  ####
  #External API
  def start_link(params) do
    [queue_named, reader_functions] = params
  	{:ok, pid} = res = GenServer.start_link(__MODULE__, {queue_named, false, reader_functions})
    
    GenServer.cast(pid, :read_from_queue)
    res 
  end
  
  #####
  # GenServer implementation

  def handle_cast(:stop, state) do
    { :noreply, state }
  end

  def handle_cast(:read_from_queue, {queue_named, _continue_reading, reader_functions}) do

    read_from_queue(queue_named, true, reader_functions)

    { :noreply, {queue_named, false, reader_functions} }
  end

  def handle_call(:process_named, _from, {queue_named, read, reader_functions}) do
    {:reply, {queue_named, read}, {queue_named, read, reader_functions} }
  end
  
  

  #def handle_call(:read_from_queue, _form, {queue_named, continue_reading, reader_functions}) do
  #  
  #  read_from_queue(queue_named, true, reader_functions)
  #
  #  { :reply, {queue_named, false, reader_functions} }
  #end
  
  defp read_from_queue(queue_named, next, reader_functions) when next == true do

    redis_pid = :poolboy.checkout(:redis_pool)

    res = GenServer.call(redis_pid, { :read_from_queue, queue_named })

    :poolboy.checkin(:redis_pool, redis_pid)

    execute_functions( res,  reader_functions)    
    

    next = check_message

    read_from_queue(queue_named, next, reader_functions)
  end

  defp read_from_queue(queue_named, next, _reader_functions) when next == false do
    child_pid = self()
    parent_pid = :gproc.where({ :n, :l, {:sub_supervisor_reader, queue_named} })
    #GenServer.cast(child_pid, :stop)
    Supervisor.terminate_child(parent_pid, child_pid)
  end

  defp execute_functions( res,  [ function | next_reader_functions]) do

    res = function.(res)
    
    execute_functions( res,  next_reader_functions)    
  end

  defp execute_functions( res,  []) do
    res    
  end

  def check_message do
    #{:"$gen_call", {#PID<0.211.0>, #Reference<0.0.1.1076>}, :check_state}
    #{:"$gen_cast", :stop}
    receive do
      {_, :stop} ->  
        false
    after 
      0 -> true
    end
  end


end