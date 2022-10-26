class TeamController < ApplicationController
  layout :determine_layout

  def index
    @members = Team.members
    @contributors = Team.contributors
  end
end