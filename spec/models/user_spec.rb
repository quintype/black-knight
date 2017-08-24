require "rails_helper"

describe User do
  it "should be valid" do
    expect(create(:user)).to be_valid
  end
end
