class LanguageController < ApplicationController


    def set_locale()
        language = params[:language] 

        if language
            if I18n.available_locales.include?(language.to_sym)
                 cookies.permanent[:locale] = language
            else
                # in case we want to show a message if the language is not available
                flash.now[:notice] =
                    "#{language} translation not available"
                logger.error flash.now[:notice]
            end
        end

        redirect_to request.referer || root_path
    end

end
