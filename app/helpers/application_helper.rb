module ApplicationHelper
  def full_title(page_title = "")
    if page_title.empty?
      title = TITLE
    else
      title = page_title + " | " + TITLE
    end
  end
end
