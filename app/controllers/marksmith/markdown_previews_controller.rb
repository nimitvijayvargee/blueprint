module Marksmith
  class MarkdownPreviewsController < ApplicationController
    helper Marksmith::SanitizerHelper

    def create
      base_url = request.base_url rescue nil
      @body = Marksmith::Renderer.new(body: params[:body], base_url: base_url).render
    end
  end
end
