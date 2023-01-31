defmodule CrawlerWeb.ViewHelpers do
  import CrawlerWeb.Gettext

  def get_status(value) do
    case value do
      :new -> gettext("New")
      :in_progress -> gettext("Crawling")
      :failed -> gettext("Failed")
      :completed -> gettext("Completed")
      _ -> gettext("Undefined")
    end
  end

  def get_column_status(value) do
    case value do
      :new -> "text-info"
      :in_progress -> "text-warning"
      :failed -> "text-danger"
      :completed -> "text-success"
      _ -> "text-muted"
    end
  end
end
