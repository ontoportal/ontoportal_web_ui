class TeamController < ApplicationController
  layout :determine_layout

  def index
    @members = Team.members
  end
end