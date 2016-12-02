defmodule RedisQueueReader.ManagerTest do
  use ExUnit.Case, async: true
  doctest RedisQueueReader

  setup do
  	Agent.start_link(fn -> Map.new(queque_continue: true, function_write_to_db_undefined: "", function_write_to_db: "") end, name: :queque_continue)
  	{:ok, redis_client_pid} = Exredis.start_link( Application.get_env(:redis_queue_reader, RedisQueueReader.Redis) )
    
    {:ok, [redis_client_pid: redis_client_pid]}
  end



  test "the redis", context do
  	Exredis.query context[:redis_client_pid], ["RPUSH", "queue_1", "1"]
  	resp = Exredis.query context[:redis_client_pid], ["RPOP", "queue_1"]
    assert "1" == resp
  end

  test "init reader", _context do
  	on_exit fn -> RedisQueueReader.Manager.destroy_all_readers_without_check_child("queue_1")   
  	              :timer.sleep(1000)
            end
  	

  	RedisQueueReader.Manager.init_reader("queue_1", [ &TestMyFunctionParsers.first_function/0, &TestMyFunctionParsers.second_function/1, &TestMyFunctionParsers.third_function/1] )
  
    [init_reader | _tail] = RedisQueueReader.Manager.list_of_init_readers  
    

    assert init_reader == "queue_1"
  end

  test "start new reader", _context do
  	on_exit fn -> RedisQueueReader.Manager.destroy_all_readers_without_check_child("queue_2")      
  	              :timer.sleep(1000)
            end

  	RedisQueueReader.Manager.init_reader("queue_2", [ &TestMyFunctionParsers.first_function/0, &TestMyFunctionParsers.second_function/1, &TestMyFunctionParsers.third_function/1] )
    
    {status, _child_pid} = RedisQueueReader.Manager.start_new_reader("queue_2")
    
    assert status == :ok
  end

  test "reader was not initilized", _context do
  	on_exit fn -> RedisQueueReader.Manager.destroy_all_readers_without_check_child("queue_1")         
  	              :timer.sleep(1000)
            end

  	RedisQueueReader.Manager.init_reader("queue_1", [ &TestMyFunctionParsers.first_function/0, &TestMyFunctionParsers.second_function/1, &TestMyFunctionParsers.third_function/1] )
    
    {:error, message} = RedisQueueReader.Manager.start_new_reader("queue_3")
    
    assert message == "Can not find queue named queue_3"
  end

  

  test "get info about child", _context do
  	on_exit fn -> RedisQueueReader.Manager.destroy_all_readers_without_check_child("queue_4")         
  	              :timer.sleep(1000)
            end

  	RedisQueueReader.Manager.init_reader("queue_4", [ &TestMyFunctionParsers.first_function/0, &TestMyFunctionParsers.second_function/1, &TestMyFunctionParsers.third_function/1] )
    
    {_status, first_child_pid}  = RedisQueueReader.Manager.start_new_reader("queue_4")
    {_status, second_child_pid} = RedisQueueReader.Manager.start_new_reader("queue_4")
    
    info = RedisQueueReader.Manager.get_info_about_child("queue_4")
    [{:undefined, info_first_child_pid, :worker, [RedisQueueReader.Reader]}, 
     {:undefined, info_second_child_pid, :worker, [RedisQueueReader.Reader]}] = info

    assert first_child_pid == info_first_child_pid and second_child_pid == info_second_child_pid
  end

  test "destroy all readers without check child", _context do
  	on_exit fn -> RedisQueueReader.Manager.destroy_all_readers_without_check_child("queue_5")         
  	              :timer.sleep(1000)
            end

  	RedisQueueReader.Manager.init_reader("queue_5", [ &TestMyFunctionParsers.first_function/0, &TestMyFunctionParsers.second_function/1, &TestMyFunctionParsers.third_function/1] )
    
    {:ok, _first_child_pid}  = RedisQueueReader.Manager.start_new_reader("queue_5")
    {:ok, _second_child_pid} = RedisQueueReader.Manager.start_new_reader("queue_5")
    
    RedisQueueReader.Manager.destroy_all_readers_without_check_child("queue_5")

    {:error, message} = RedisQueueReader.Manager.start_new_reader("queue_5")
    
    assert message == "Can not find queue named queue_5"
  end

  
  test "stop queue reader if reader is not exist", _context do
    on_exit fn -> RedisQueueReader.Manager.destroy_all_readers_without_check_child("queue_6")            
  	              :timer.sleep(1000)
            end
  	
  	RedisQueueReader.Manager.init_reader("queue_6", [ &TestMyFunctionParsers.first_function/0, &TestMyFunctionParsers.second_function/1, &TestMyFunctionParsers.third_function/1] )
       
    
    {:ok, message} = RedisQueueReader.Manager.stop_reader_of("queue_6")
    
    assert message == "can not find child"
  end

  test "stop queue reader", _context do
    on_exit fn -> RedisQueueReader.Manager.destroy_all_readers_without_check_child("queue_7")            
  	              :timer.sleep(1000)
            end
  	
  	RedisQueueReader.Manager.init_reader("queue_7", [ &TestMyFunctionParsers.first_function/0, &TestMyFunctionParsers.second_function/1, &TestMyFunctionParsers.third_function/1] )
    
    {:ok, _first_child_pid}  = RedisQueueReader.Manager.start_new_reader("queue_7")
    {:ok, _second_child_pid} = RedisQueueReader.Manager.start_new_reader("queue_7")
    
    RedisQueueReader.Manager.stop_reader_of("queue_7")
    :timer.sleep(5000)
    info = RedisQueueReader.Manager.get_info_about_child("queue_7")
        
    assert length(info) == 1
  end

  test "check functions are executed", context do
    on_exit fn -> RedisQueueReader.Manager.destroy_all_readers_without_check_child("queue_8")            
  	              :timer.sleep(1000)
            end

    Exredis.query context[:redis_client_pid], ["RPUSH", "queue_8", "write"]
  	
  	RedisQueueReader.Manager.init_reader("queue_8", [ &TestMyFunctionParsers.first_function/0, &TestMyFunctionParsers.second_function/1, &TestMyFunctionParsers.third_function/1] )
    
    {:ok, _first_child_pid}  = RedisQueueReader.Manager.start_new_reader("queue_8")
    :timer.sleep(1000)
    
    function_write_to_db_undefined = Agent.get(:queque_continue, fn state -> state.function_write_to_db_undefined end)
    function_write_to_db = Agent.get(:queque_continue, fn state -> state.function_write_to_db end)
    
    assert function_write_to_db == "write" and function_write_to_db_undefined == "undefined"
  end



end
