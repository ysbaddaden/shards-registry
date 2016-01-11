class GuidesController < ApplicationController
  getter! :page

  def show
    name = params["name"]?
    name = "index" if name.blank?
    @page = Page.find(name)
  end
end
