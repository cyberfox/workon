module StatusesHelper
  def mark_done(status, inner)
    status.done? ? "<strike>" + inner + "</strike>" : inner
  end
end
