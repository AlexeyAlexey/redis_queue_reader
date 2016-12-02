defmodule TestMyFunctionParsers do
  def first_function() do
    #function must return true or false
    Agent.get(:queque_continue, fn state -> state.queque_continue end)
  end
  def second_function(res) do
    #res is a variable that can be equal to :undefined or the information read from the queue 
    res
  end

  def third_function(:no_connection) do
    #The redis DB has not been connected
    IO.puts "The redis DB has not been connected"
  end
  def third_function(res) do
    #res  is a variable that can be equal to the result of the calculation of the second function (second_function/1)
    function_write_to_db(res)
    res
  end

  def function_write_to_db(:undefined) do
    #IO.puts "undefined"
    Agent.update(:queque_continue, fn state -> Map.put(state, :function_write_to_db_undefined, "undefined") end)
  end
  def function_write_to_db(str) do
    Agent.update(:queque_continue, fn state -> Map.put(state, :function_write_to_db, str) end)
    #IO.puts str
  end
end