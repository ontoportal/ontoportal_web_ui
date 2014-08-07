class ResourceIndexResultPaginatable < WillPaginate::Collection
  attr_accessor :totalResults, :offset, :limit, :acronym

  def initialize(hash)
    return if hash.nil?

    # Our custom attributes
    self.totalResults = hash[:totalResults]
    self.offset = hash[:offset]
    self.limit = hash[:limit]
    self.acronym = hash[:acronym]

    # Fill out attributes needed by will_paginate
    page_number = (self.offset / self.limit) + 1
    @current_page = page_number
    @per_page = self.limit
    self.total_entries = self.totalResults

    # Put the array elements in place
    self.replace(hash[:elements])
  end
end