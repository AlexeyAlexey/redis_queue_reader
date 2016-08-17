Developing

# RedisQueueReader

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

#redis connection
config :redis_queue_reader, RedisQueueReader.Redis,
  url: "redis://127.0.0.1:6379",
  reconnect: :no_reconnect,
  max_queue: :infinity
 
#pool of redis connections 
config :redis_queue_reader, RedisQueueReader.Supervisor,
  redis_pool: %{size: 5, max_overflow: 0}

```


0) iex --name redis_queue_reader@127.0.0.1 --cookie 123 -S mix


```elixir
defmodule MyFunctionParsers do
  def function1(res) do
    IO.puts res
    res
  end
  def function2(res) do
    IO.puts res
    function_to_db(res)
    :timer.sleep(10000)
    res
  end
  def function_to_db(:undefined) do
    IO.puts " undefined undefined undefined"
  end
  def function_to_db(str) do
    IO.puts str
  end
end
```

###Interface

1) RedisQueueReader.Manager.init_reader("queue_1", [ &MyFunctionParsers.function1/1, &MyFunctionParsers.function2/1] )

2) RedisQueueReader.Manager.start_new_reader("queue_1")

3) RedisQueueReader.Manager.stop_reader_of("queue_1")

4) RedisQueueReader.Manager.destroy_all_readers_without_check_child("queue_1")

5) RedisQueueReader.Manager.list_of_init_readers => ["queue_3", "queue_2", "queue_1"]



