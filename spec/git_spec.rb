RSpec.describe GitDiffIcult::Git do
  it ".has_diff?" do
    expect(GitDiffIcult::Diff.has_diff?.to eql(true)
  end
end
