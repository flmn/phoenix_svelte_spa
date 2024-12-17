defmodule PhoenixSvelteSpaWeb.PageController do
  use PhoenixSvelteSpaWeb, :controller

  def index(conn, _params) do
    index_path = Path.join(:code.priv_dir(:phoenix_svelte_spa), "static/index.html")

    conn
    |> put_resp_header("content-type", "text/html")
    |> send_file(200, index_path)
  end
end
