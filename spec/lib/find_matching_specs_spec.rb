require 'spec_helper'
require 'fileutils'

require './spec/support/run_inside_temp_dir_support'
require './lib/find_matching_specs'

RSpec.describe FindMatchingSpecs do
  include RunInsideTempDirSupport

  let(:files) { Array.new }
  let(:specs) { Array.new }

  let(:matcher) { described_class.new(files) }

  def create_temp_file(filename)
    File.new(filename, 'w')
  end

  before do
    Dir.mkdir('spec') unless Dir.exists?('spec')

    (files + specs).each { |filename| create_temp_file(filename) }
  end

  describe '#call' do
    subject(:matching_specs) { matcher.call }

    context 'when no files are given' do
      it 'returns no matching specs' do
        expect(matching_specs).to be_empty
      end
    end

    context 'when a file is given' do
      context 'that has a matching spec' do
        let(:files) { [ 'file.rb' ] }
        let(:specs) { [ 'spec/file_spec.rb' ] }

        it 'matches the spec file' do
          expect(matching_specs).to include './spec/file_spec.rb'
        end

        context 'that is not a ruby file' do
          let(:files) { [ 'file.js' ] }

          it 'does not match the spec' do
            expect(matching_specs).to_not include './spec/file_spec.rb'
          end
        end
      end

      context 'that is a spec itself' do
        let(:files) { [ 'spec/file_spec.rb' ] }

        it 'matches the spec with itself' do
          expect(matching_specs).to include './spec/file_spec.rb'
        end
      end

      context 'that has no matching spec' do
        let(:files) { [ 'file.rb' ] }

        it 'returns no matching specs' do
          expect(matching_specs).to be_empty
        end
      end
    end

    context 'when multiple files are given' do
      context 'when one file has a matching spec' do
        let(:files) { [ 'some.rb', 'file.rb' ] }
        let(:specs) { [ 'spec/some.rb' ] }

        it 'matches the spec for the tested file' do
          expect(matching_specs).to include './spec/some.rb'
        end
      end

      context 'when both files have matching specs' do
        let(:files) { [ 'some.rb', 'file.rb' ] }
        let(:specs) { [ 'spec/some_spec.rb', 'spec/file_spec.rb' ] }

        it 'matches specs for both files' do
          specs.each do |spec|
            expect(matching_specs).to include "./#{spec}"
          end
        end

        context 'but one is not a ruby file' do
          let(:files) { [ 'some.txt', 'file.rb' ] }

          it 'returns matching specs for ruby files' do
            expect(matching_specs).to include './spec/file_spec.rb'
          end

          it 'does not match specs for non-ruby files' do
            expect(matching_specs).to_not include './spec/some_spec.rb'
          end
        end
      end

      context 'when neither file has a matching spec' do
        let(:files) { [ 'some.txt', 'files.rb' ] }

        it 'returns no matching specs' do
          expect(matching_specs).to be_empty
        end
      end
    end
  end
end