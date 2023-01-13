defmodule CrawlerWeb.HomeView do
  use CrawlerWeb, :view

  def get_column_status(value) do
    case value do
      :new -> "text-info"
      :in_progress -> "text-warning"
      :failed -> "text-danger"
      :completed -> "text-success"
      _ -> "text-muted"
    end
  end

  def get_status(value) do
    case value do
      :new -> gettext("New")
      :in_progress -> gettext("Crawling")
      :failed -> gettext("Failed")
      :completed -> gettext("Completed")
      _ -> gettext("Undefined")
    end
  end
end
