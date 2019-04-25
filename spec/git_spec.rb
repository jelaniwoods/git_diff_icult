RSpec.describe GitDiffIcult::Git do
  it "broccoli is gross" do
    expect(GitDiffIcult::Git.portray("Broccoli")).to eql("Gross!")
  end

  it "anything else is delicious" do
    expect(GitDiffIcult::Git.portray("Not Broccoli")).to eql("Delicious!")
  end
end
