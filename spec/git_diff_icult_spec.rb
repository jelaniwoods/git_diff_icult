require "git_diff_icult"

RSpec.describe GitDiffIcult do
  it "has a version number" do
    expect(GitDiffIcult::VERSION).not_to be nil
  end

  it "does something not-useful" do
    expect(false).to eq(false)
  end
end
