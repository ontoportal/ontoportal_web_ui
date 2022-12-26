class SympaSubscribeMailer < ApplicationMailer

    def register_for_announce_list

        unless $SUBSCRIBE_LIST_NAME.nil? || $SUBSCRIBE_LIST_NAME.empty?
            @user = params[:user]
            @sub = "subscribe #{$SUBSCRIBE_LIST_NAME} #{@user.firstName} #{@user.lastName}"
            mail(to: $SUBSCRIBE_SERVICE_MAIL, from: @user.email, subject: @sub)
        end
       
      end

end
