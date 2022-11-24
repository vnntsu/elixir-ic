defmodule CrawlerWeb.LivenessRequestTest do
  use CrawlerWeb.ConnCase, async: true

  test "returns 200", %{conn: conn} do
    conn =
      get(
        conn,
        "#{Application.get_env(:crawler, CrawlerWeb.Endpoint)[:health_path]}/liveness"
      )

    assert response(conn, :ok) =~ "alive"
  end
end
