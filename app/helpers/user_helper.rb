module UserHelper 

    # factory methode
    def subscribe(user)
        if $SUBSCRIBE_SERVICE.upcase == "SYMPA"
            return SympaSubscribeMailer.with(user).register_for_announce_list.deliver_now;
        end
    end

end