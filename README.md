Experiment

# RedisQueueReader

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `redis_queue_reader` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:redis_queue_reader, "~> 0.1.0"}]
    end
    ```

  2. Ensure `redis_queue_reader` is started before your application:

    ```elixir
    def application do
      [applications: [:redis_queue_reader]]
    end
    ```



0) iex --name redis_queue_reader@127.0.0.1 --cookie 123 -S mix


```elixir
defmodule MyFunctionParsers do
  def function1(res) do
    IO.puts res
    IO.puts "1"
    res
  end
  def function2(res) do
    IO.puts res
    IO.puts "2"
    function_to_db(res)
    :timer.sleep(10000)
    res
  end
  def function_to_db(:undefined) do
    IO.puts " undefined undefined undefined"
  end
  def function_to_db(str) do
    IO.puts str
    IO.puts "str"
  end
end
```

1) RedisQueueReader.Manager.init_parser("queue_1", [ &MyFunctionParsers.function1/1, &MyFunctionParsers.function2/1] )


2) RedisQueueReader.Manager.start_new_parser("queue_1")

3) RedisQueueReader.Manager.stop_parser_of("queue_1")

4) RedisQueueReader.Manager.destroy_all_parsers_without_check_child("queue_1")

5) RedisQueueReader.Manager.list_of_init_parsers => ["queue_3", "queue_2", "queue_1"]



