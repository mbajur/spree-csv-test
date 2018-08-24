require 'rails_helper'

describe ProductsCsvImporter::RowHandler do
  let(:service) do
    described_class.new(row, taxons: taxonomy.taxons,
                             shipping_category: shipping_category)
  end

  let(:valid_row) do
    {
      'name' => 'Product name',
      'slug' => 'product-name',
      'description' => 'Product description',
      'availability_date' => '2017-12-04T14:55:22.913Z',
      'price' => '12,99',
      'stock_total' => '12',
      'category' => 'Bags'
    }
  end
  let(:row) { valid_row }

  let(:taxonomy) { create(:taxonomy) }
  let(:shipping_category) { create(:shipping_category) }

  describe '#call' do
    subject { service.call }

    context 'when row is invalid' do
      let(:row) { valid_row.merge({ 'name' => nil, 'price' => nil }) }

      it 'returns a proper result with errors' do
        status, payload = subject

        expect(status).to eq :row_invalid
        expect(payload.content).to eq row.symbolize_keys
        expect(payload.errors).to include 'name is missing'
        expect(payload.errors).to include 'price is missing'
      end
    end

    context 'when row is valid and product is created' do
      let(:product) { create(:product) }
      let(:row) { valid_row }

      before do
        allow_any_instance_of(ProductsCsvImporter::ProductHandler)
          .to receive(:call)
          .and_return([:created, product])
      end

      it 'returns a proper result with product' do
        status, payload = subject

        expect(status).to eq :created
        expect(payload).to eq product
      end
    end

    context 'when row is valid but product already exists' do
      let(:product) { create(:product) }
      let(:row) { valid_row }

      before do
        allow_any_instance_of(ProductsCsvImporter::ProductHandler)
          .to receive(:call)
          .and_return([:exists, product])
      end

      it 'returns a proper result with product' do
        status, payload = subject

        expect(status).to eq :exists
        expect(payload).to eq product
      end
    end

    context 'when row is valid but product is invalid' do
      let(:product) { create(:product) }
      let(:row) { valid_row }

      before do
        allow_any_instance_of(ProductsCsvImporter::ProductHandler)
          .to receive(:call)
          .and_return([:invalid, product])
      end

      it 'returns a proper result with product' do
        status, payload = subject

        expect(status).to eq :invalid
        expect(payload).to eq product
      end
    end
  end

  describe '#serialized_row' do
    subject { service.send(:serialized_row) }
    let(:row) { valid_row }

    it { is_expected.to be_kind_of ProductsCsvImporter::Row }
  end

  describe '#matched_taxons' do
    subject { service.send(:matched_taxons) }

    before do
      allow(service)
        .to receive(:serialized_row)
        .and_return(double(category: category))
    end

    context 'when row category matches any taxon' do
      let(:category) { taxonomy.taxons.last.name }

      it 'returns array with matched taxon' do
        expect(subject).to match_array taxonomy.taxons.last
      end
    end

    context 'when row category do not matches any taxon' do
      let(:category) { 'No such category' }

      it 'returns empty array' do
        expect(subject).to be_empty
      end
    end
  end
end
