require 'rails_helper'

describe ProductsCsvImporter::Row do
  let(:service) { described_class.new(row) }
  subject { service }

  let(:valid_row) do
    {
      name: 'Product name',
      description: 'Product description',
      price: '12,99',
      availability_date: '2017-12-30 14:55:22 UTC',
      slug: 'product-name',
      stock_total: 15,
      category: 'Bags'
    }
  end

  context 'when row is fully valid' do
    let(:row) { valid_row }
    it { is_expected.to be_valid }

    it 'assigns all the attributes' do
      expect(subject.name).to eq 'Product name'
      expect(subject.description).to eq 'Product description'
      expect(subject.price).to eq 12.99
      expect(subject.available_on).to eq Time.utc(2017, 12, 30, 14, 55, 22)
      expect(subject.slug).to eq 'product-name'
      expect(subject.stock_total).to eq 15
      expect(subject.category).to eq 'Bags'
    end
  end

  describe 'name serialization and validation' do
    context 'when name is absent' do
      let(:row) { valid_row.merge(name: nil) }

      it { is_expected.to_not be_valid }
      it { expect(service.full_errors).to include 'name must be filled' }
    end
  end

  describe 'price serialization and validation' do
    context 'when price is absent' do
      let(:row) { valid_row.merge(price: nil) }

      it { is_expected.to_not be_valid }
      it { expect(service.full_errors).to include 'price must be filled' }
    end

    context 'when price is invalid' do
      let(:row) { valid_row.merge(price: 'invalid price') }

      it { is_expected.to_not be_valid }
      it { expect(service.full_errors).to include 'price must be Float' }
    end

    context 'when price is negative' do
      let(:row) { valid_row.merge(price: '-10,20') }

      it { is_expected.to_not be_valid }
      it { expect(service.full_errors).to include 'price must be greater than 0.0' }
    end

    context 'when price is string and is a valid float' do
      let(:row) { valid_row.merge(price: 10.20) }

      it { is_expected.to be_valid }
      it { expect(service.price).to eq 10.20 }
    end

    context 'when price is string and contains comma instead of a dot' do
      let(:row) { valid_row.merge(price: '10,99') }

      it { is_expected.to be_valid }
      it { expect(service.price).to eq 10.99 }
    end
  end

  describe 'availability_date serialization and validation' do
    context 'when availability_date is absent' do
      let(:row) { valid_row.merge(availability_date: nil) }

      it { is_expected.to be_valid }
    end

    context 'when availability_date is valid' do
      let(:row) { valid_row.merge(availability_date: Time.new(2018, 8, 31, 12, 20)) }

      it { is_expected.to be_valid }
      it { expect(service.available_on).to eq Time.new(2018, 8, 31, 12, 20) }
    end

    context 'when availability_date is valid but string' do
      let(:row) { valid_row.merge(availability_date: '2017-12-30 14:55:22 UTC') }

      it { is_expected.to be_valid }
      it { expect(service.available_on).to eq Time.utc(2017, 12, 30, 14, 55, 22) }
    end

    context 'when availability_date is valid but string' do
      let(:row) { valid_row.merge(availability_date: 'wrong date') }

      it { is_expected.to_not be_valid }
      it { expect(service.full_errors).to include 'available_on must be Time' }
    end
  end

  describe 'stock_total serialization and validation' do
    context 'when stock_total is nil' do
      let(:row) { valid_row.merge(stock_total: nil) }

      it { is_expected.to_not be_valid }
      it { expect(service.full_errors).to include 'stock_total must be filled' }
    end

    context 'when stock_total is empty' do
      let(:row) { valid_row.merge(stock_total: '') }

      it { is_expected.to_not be_valid }
      it { expect(service.full_errors).to include 'stock_total must be filled' }
    end

    context 'when stock_total is valid but string' do
      let(:row) { valid_row.merge(stock_total: '10') }

      it { is_expected.to be_valid }
      it { expect(service.stock_total).to eq 10 }
    end

    context 'when stock_total is valid' do
      let(:row) { valid_row.merge(stock_total: 10) }

      it { is_expected.to be_valid }
      it { expect(service.stock_total).to eq 10 }
    end

    context 'when stock_total is negative' do
      let(:row) { valid_row.merge(stock_total: '-10') }

      it { is_expected.to_not be_valid }
      it { expect(service.full_errors).to include 'stock_total must be greater than 0' }
    end
  end
end
