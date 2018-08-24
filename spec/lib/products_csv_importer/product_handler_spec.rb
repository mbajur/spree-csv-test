require 'rails_helper'

describe ProductsCsvImporter::ProductHandler do
  let(:service) do
    described_class.new(row: serialized_row,
                        taxons: taxonomy.taxons,
                        shipping_category: shipping_category)
  end

  let(:taxonomy) { create(:taxonomy) }
  let(:shipping_category) { create(:shipping_category) }
  let!(:stock_location) { create(:stock_location) }

  let(:valid_row) do
    {
      name: 'Product name',
      slug: 'product-name',
      description: 'Product description',
      availability_date: '2017-12-04T14:55:22.913Z',
      price: '12,99',
      stock_total: '12',
      category: 'Bags'
    }
  end
  let(:row) { valid_row }
  let(:serialized_row) { ProductsCsvImporter::Row.new(row) }

  describe '#call' do
    subject { service.call }

    context 'when product already exists' do
      let!(:product) { create(:product) }
      let(:row) { valid_row.merge(slug: product.slug) }

      it 'returns a proper result with product' do
        status, payload = subject

        expect(status).to eq :exists
        expect(payload).to eq product
      end
    end

    context 'when product has been successfully created' do
      let(:row) { valid_row }

      it 'returns a proper result with product' do
        status, payload = subject

        expect(status).to eq :created
        expect(payload).to eq Spree::Product.last
        expect(payload.total_on_hand).to eq serialized_row.stock_total
      end
    end

    context 'when product is invalid' do
      let(:row) { valid_row.merge(name: nil) }

      it 'returns a proper result with product' do
        status, payload = subject

        expect(status).to eq :invalid
        expect(payload.errors.full_messages).to include "Name can't be blank"
      end
    end
  end
end
