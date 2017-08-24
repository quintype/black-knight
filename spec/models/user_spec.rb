require "rails_helper"

describe User do
  it "should be valid" do
    expect(create(:user)).to be_valid
  end

  context "two factor auth" do
    let(:user) { create(:user, password: "password", unconfirmed_otp_secret: User.generate_otp_secret) }
    let(:current_otp) { user.otp(user.unconfirmed_otp_secret).at(Time.now) }

    it "allows you to set the two factor password" do
      user.activate_two_factor(password: "password", otp_attempt: current_otp)
      expect(user.errors).to be_empty
      expect(user.otp_required_for_login).to be true
    end

    it "does not allow setting two factor if the password is wrong" do
      user.activate_two_factor(password: "somethingelse", otp_attempt: current_otp)
      expect(user.errors[:password]).not_to be_empty
    end

    it "does not allow setting two factor auth if the otp is wrong" do
      user.activate_two_factor(password: "password", otp_attempt: "111111")
      expect(user.errors[:otp_attempt]).not_to be_empty
    end

    it "allows removal of two factor auth if the password is correct" do
      user.activate_two_factor(password: "password", otp_attempt: current_otp)
      user.deactivate_two_factor(password: "password")
      expect(user.errors).to be_empty
      expect(user.otp_required_for_login).to be false
      expect(user.otp_secret).to be nil
    end

    it "doesn't allow removal if password is wrong" do
      user.activate_two_factor(password: "password", otp_attempt: current_otp)
      user.deactivate_two_factor(password: "somethingelse")
      expect(user.errors[:password]).not_to be_empty
    end
  end
end
