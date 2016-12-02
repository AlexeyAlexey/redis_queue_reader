defmodule RedisQueueReader.Mixfile do
  use Mix.Project

  def project do
    [app: :redis_queue_reader,
     version: "0.1.0",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :exredis, :poolboy, :gproc],
     mod: {RedisQueueReader, []}]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{ :exredis, ">= 0.2.4" },
     { :poolboy, "~> 1.5"   },
     { :gproc,   "~> 0.5.0" }]
  end

  defp description do
    """
    This application reads from a redis queue (RPOP) and then executes functions from a list. 
    The first function from the list does not receive parameter and must return true or false. 
    The second function from the list takes a result of reading from the redis queue (:undefined, :no_connection or string that have been read from the redis queue). 
    Every next function from the list gets the result of the calculation of the previous one.

    While the first function return false the next functions from list not be executed
    """
  end

  defp package do
    [# These are the default files included in the package
     name: :redis_queue_reader,
     files: ["lib", "mix.exs", "README*"],
     maintainers: ["Alexey Kondratenko"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/AlexeyAlexey/redis_queue_reader"}]
  end
end
