# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RakeGit do
  it 'has a version number' do
    expect(RakeGit::VERSION).not_to be_nil
  end
end
