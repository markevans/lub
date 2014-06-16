class HomeController < ApplicationController
  def index
    @transactions = Transaction.by_latest
  end
end
