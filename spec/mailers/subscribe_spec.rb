require "rails_helper"

RSpec.describe SubscribeMailer, type: :mailer do
  
  describe "register for announce list" do
    let(:mail) { SubscribeMailer.register_for_announce_list("hz_haddad@esi.dz","zineddine","haddad") }

    it "renders the headers" do
      expect(mail.subject).to eq("subscribe #{$ANNOUNCE_LIST} zineddine haddad")
      expect(mail.to).to eq($ANNOUNCE_SERVICE_HOST)
      expect(mail.from).to eq("hz_haddad@esi.dz")
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("")
    end

  end

  describe "unregister for announce list" do
    let(:mail) { SubscribeMailer.unregister_for_announce_list("hz_haddad@esi.dz") }

    it "renders the headers" do
      expect(mail.subject).to eq("unsubscribe #{$ANNOUNCE_LIST}")
      expect(mail.to).to eq($ANNOUNCE_SERVICE_HOST)
      expect(mail.from).to eq("hz_haddad@esi.dz")
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("")
    end

  end

end
