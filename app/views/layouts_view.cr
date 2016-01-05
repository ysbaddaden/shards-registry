class LayoutsView < ApplicationView
  def initialize(@controller)
  end

  def flash_message
    if session["flash"]?
      JSON.parse(session.delete("flash").to_s)
    end
  rescue
    nil
  end
end
