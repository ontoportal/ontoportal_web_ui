# frozen_string_literal: true

module SessionsHelper
  def welcome_message(user)
    tag.div do
      concat('Welcome ')
      concat(tag.span(user.username, class: 'fw-bold'))
      concat('!')

      if user.customOntology.present?
        concat(' The display is now based on your ')
        concat(link_to('Custom Ontology Set', user_path(user.username)))
        concat('.')
      end
    end
  end
end
