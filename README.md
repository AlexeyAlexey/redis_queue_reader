Developing

# RedisQueueReader

This application reads from a redis queue (RPOP) and then executes functions from a list. The first function from the list takes a result of reading from the redis queue (:undefined or string that have been read from the redis queue). Every next function from the list gets the result of the calculation of the previous one.   


**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `redis_queue_reader` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:redis_queue_reader, git: "https://github.com/AlexeyAlexey/redis_queue_reader.git"}]
    end
    ```

  2. Ensure `redis_queue_reader` is started before your application:

    ```elixir
    def application do
      [applications: [:redis_queue_reader]]
    end
    ```


[Exapmle (read from queue (redis) and than write to a DB)](https://github.com/AlexeyAlexey/redis_queue_reader_parser)

###Config file

```elixir

#Redis connection
#The application uses the ‘exredis’(https://github.com/artemeff/exredis) 
#library for #working with the redis

config :redis_queue_reader, RedisQueueReader.Redis,
  url: "redis://127.0.0.1:6379",
  reconnect: :no_reconnect,
  max_queue: :infinity
 
#The application uses ‘poolboy’ for creating a pool of redis connections
#size: maximum pool size (https://github.com/devinus/poolboy)
#max_overflow: maximum number of workers created if the pool is empty

config :redis_queue_reader, RedisQueueReader.Supervisor,
  redis_pool: %{size: 5, max_overflow: 0}

```


###Interface

1) RedisQueueReader.Manager.init_reader("queue_1", [ &MyFunctionParsers.first_function/1, &MyFunctionParsers.second_function/1] )

2) RedisQueueReader.Manager.start_new_reader("queue_1")

3) RedisQueueReader.Manager.stop_reader_of("queue_1")

4) RedisQueueReader.Manager.destroy_all_readers_without_check_child("queue_1")

5) RedisQueueReader.Manager.list_of_init_readers => ["queue_3", "queue_2", "queue_1"]



###Example

0) iex --name redis_queue_reader@127.0.0.1 --cookie 123 -S mix


```elixir
defmodule MyFunctionParsers do
  def first_function(res) do
    #res is a variable that can be equal to :undefined or the information read from the queue 
    IO.puts res
    res
  end
  def second_function(res) do
    #res  is a variable that can be equal to the result of the calculation of the first function (first_function/1)
    IO.puts res
    function_write_to_db(res)
    :timer.sleep(1000)
    res
  end
  def function_write_to_db(:undefined) do
    IO.puts "undefined undefined undefined"
  end
  def function_write_to_db(str) do
    IO.puts str
  end
end

```


**The following function creates a process that will supervise readers from the queue**

```elixir
RedisQueueReader.Manager.init_reader("queue_1", [ &MyFunctionParsers.first_function/1, &MyFunctionParsers.second_function/1] )
```

The function receives two parameters. The first parameter is the name of the redis queue.
The second parameter is a list of functions. Each function in the list receives one parameter (the arity of functions is one).
The parameter of the first function (&MyFunctionParsers.first_function/1) in the list can receive the following values **:undefined** or **string** that were read from the redis queue.  



**To create a reader for the queue.** 

```elixir
RedisQueueReader.Manager.start_new_reader("queue_1")
```

This function creates a process that reads from the queue and executes functions from the list of functions that have been set as the second parameter of the function named **&RedisQueueReader.Manager.init_reader/2** (  RedisQueueReader.Manager.init_reader("queue_1", [ &MyFunctionParsers.first_function/1, &MyFunctionParsers.second_function/1] ) )

For adding a reader of the queue you should repeat execution of the function  

```elixir
RedisQueueReader.Manager.start_new_reader("queue_1")
```

**To stop the first reader of the queue**

```elixir
RedisQueueReader.Manager.stop_reader_of("queue_1")
```


**To destroy all readers of the queue**

```elixir
RedisQueueReader.Manager.destroy_all_readers_without_check_child("queue_1")
```

If you use this function, you have to create a process that will supervise readers of the queue (&RedisQueueReader.Manager.init_reader/2 )


**To return all initialized readers**

```elixir
RedisQueueReader.Manager.list_of_init_readers #=> ["queue_3", "queue_2", "queue_1"]
```