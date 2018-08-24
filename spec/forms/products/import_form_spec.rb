require 'rails_helper'

describe Products::ImportForm, type: :model do
  let(:form) { described_class.new(params) }
  let(:taxonomy) { create(:taxonomy) }
  let(:shipping_category) { create(:shipping_category) }

  it { is_expected.to validate_presence_of(:file) }
  it { is_expected.to validate_presence_of(:taxonomy_id) }
  it { is_expected.to validate_presence_of(:shipping_category_id) }

  describe '#save' do
    subject { form.save }

    let(:valid_params) do
      {
        file: File.new(fixture_path + '/files/products.csv'),
        taxonomy_id: taxonomy.id,
        shipping_category_id: shipping_category.id,
      }
    end

    context 'when params are valid' do
      let(:params) { valid_params }

      it { expect(form).to be_valid }

      it 'calls ProductsCsvImporter::Import' do
        expect(ProductsCsvImporter::Import)
          .to receive(:new)
          .with(
            file: valid_params[:file],
            taxonomy: valid_params[:taxonomy_id],
            shipping_category: valid_params[:shipping_category_id]
          ).and_call_original

        expect_any_instance_of(ProductsCsvImporter::Import)
          .to receive(:call)

        subject
      end
    end

    context 'when params are not valid' do
      let(:params) { valid_params.merge(file: nil) }

      it { expect(form).to be_invalid }
      it { is_expected.to be false }
    end
  end
end
