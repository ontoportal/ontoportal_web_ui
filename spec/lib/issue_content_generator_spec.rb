# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KGCL::IssueContentGenerator do
  it 'generates issue content for new synonym change requests' do
    params = {
      operation: KGCL::Operations::NEW_SYNONYM,
      pref_label: 'PSMNSW',
      path_info: 'MONDO_0013494',
      dbxrefs: %w[SCTID:804955009 OMOP:377535],
      acronym: 'MONDO',
      orcid: 'https://orcid.org/0000-0002-8169-9049',
      synonym: 'Broad',
      subtypes: ['sleep walking disorder', 'sleepwalking disorder', 'sleep walking', 'somnambulism'],
      username: 'Daenerys Targaryen'
    }

    title = 'Add synonym: PSMNSW'
    body = <<~HEREDOC.chomp
      @bioportal_agent requests:

      **MONDO term (ID and label)**
      PSMNSW (`MONDO_0013494`)

      **Synonym to be added**
      Broad

      **Synonym subtype: ie, broad/exact/narrow/related**
        * sleep walking disorder
        * sleepwalking disorder
        * sleep walking
        * somnambulism

      **Database cross reference for the synonym** such as PubMed ID (in the format PMID:XXXXXX) or a cross-reference to another ontology, like OMIM or Orphanet.
        * `SCTID:804955009`
        * `OMOP:377535`

      **Your nano-attribution (ORCID)**
      If you don't have an ORCID, you can sign up for one [here](https://orcid.org/)
      https://orcid.org/0000-0002-8169-9049

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
      path_info: 'MONDO_0009662',
      comment: "I don't think this is correct!",
      username: 'Sansa Stark'
    }

    title = 'Remove synonym "Gus deficiency" from mucopolysaccharidosis type 7 (MONDO_0009662)'
    body = <<~HEREDOC.chomp
      @bioportal_agent requests:

      * `remove synonym "Gus deficiency" from MONDO_0009662`, comments: I don't think this is correct!

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
