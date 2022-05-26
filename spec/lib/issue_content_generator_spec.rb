# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KGCL::IssueContentGenerator do
  it 'generates issue content for new synonym change requests' do
    params = {
      operation: KGCL::Operations::NEW_SYNONYM,
      synonym: 'taste-bud cell',
      pref_label: 'taste receptor cell',
      curie: 'CL:0000209',
      comment: 'I really, really want to have this new synonym added!',
      username: 'Daenerys Targaryen'
    }

    title = 'New synonym "taste-bud cell" for taste receptor cell (CL:0000209)'
    body = <<~HEREDOC.chomp
      `new synonym "taste-bud cell" for CL:0000209`

      Comment: I really, really want to have this new synonym added!

      This request comes from BioPortal user: Daenerys Targaryen
    HEREDOC

    content = KGCL::IssueContentGenerator.generate(params)
    expect(content[:title]).to eq(title)
    expect(content[:body]).to eq(body)
  end

  it 'generates issue content for remove synonym change requests' do
    params = {
      operation: KGCL::Operations::REMOVE_SYNONYM,
      synonym: 'Gus deficiency',
      pref_label: 'mucopolysaccharidosis type 7',
      curie: 'MONDO:0009662',
      comment: "I don't think this is correct!",
      username: 'Sansa Stark'
    }

    title = 'Remove synonym "Gus deficiency" from mucopolysaccharidosis type 7 (MONDO:0009662)'
    body = <<~HEREDOC.chomp
      `remove synonym "Gus deficiency" from MONDO:0009662`

      Comment: I don't think this is correct!

      This request comes from BioPortal user: Sansa Stark
    HEREDOC

    content = KGCL::IssueContentGenerator.generate(params)
    expect(content[:title]).to eq(title)
    expect(content[:body]).to eq(body)
  end

  it 'raises an error for invalid KGCL operations' do
    params = { operation: 'bogus operation' }
    msg = 'Invalid KGCL operation: bogus operation'
    expect { KGCL::IssueContentGenerator.generate(params) }.to raise_error(ArgumentError, msg)
  end
end
