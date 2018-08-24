require 'rails_helper'

describe ProductsCsvImporter::Import do
  let(:service) { described_class.new(params) }
  let(:taxonomy) { create(:taxonomy) }
  let(:shipping_category) { create(:shipping_category) }

  let(:params) do
    {
      file: File.new(fixture_path + '/files/products.csv'),
      taxonomy: taxonomy,
      shipping_category: shipping_category,
    }
  end

  describe '#call' do
    subject { service.call }

    it 'calls ProductsCsvImporter::RowHandler for each csv row but headers' do
      # products.csv has 22 lines while first one is a headers line
      expect(ProductsCsvImporter::RowHandler)
        .to receive(:new)
        .exactly(21).times
        .and_call_original

      subject
    end
  end

  describe '#handle_row' do
    subject { service.send(:handle_row, name: 'fake name') }

    before do
      allow_any_instance_of(ProductsCsvImporter::RowHandler)
        .to receive(:call)
        .and_return(response)
    end

    context 'when product for given row already exists' do
      let(:product) { create(:product) }
      let(:response) { [:exists, product] }

      it 'adds it to existing_products array' do
        subject
        expect(service.existing_products).to match_array [product]
      end
    end

    context 'when product for given row has been created' do
      let(:product) { create(:product) }
      let(:response) { [:created, product] }

      it 'adds it to created_products array' do
        subject
        expect(service.created_products).to match_array [product]
      end
    end

    context 'when product for given row is invalid' do
      let(:product) { attributes_for(:product) }
      let(:response) { [:invalid, product] }

      it 'adds it to invalid_products array' do
        subject
        expect(service.invalid_products).to match_array [product]
      end
    end

    context 'when given row is malformed' do
      let(:response) { [:row_invalid, { foo: 'bar' }] }

      it 'adds it to existing_products array' do
        subject
        expect(service.invalid_rows).to match_array [{ foo: 'bar' }]
      end
    end
  end
end
