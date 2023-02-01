defmodule CrawlerWeb.HomeView do
  use CrawlerWeb, :view

  import CrawlerWeb.ViewHelpers

  def operation_selected?(selected_operator, operator) do
    if selected_operator == operator do
      "selected"
    else
      ""
    end
  end
end
