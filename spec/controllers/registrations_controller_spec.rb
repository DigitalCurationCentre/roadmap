# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegistrationsController, type: :controller do

  before(:each) do
    @org = create(:org, is_other: false)
    @user = create(:user, org: @org)
  end

  context "private methods" do

    before(:each) do
      @controller = described_class.new
    end

    describe "#handle_org(attrs:)" do

      before(:each) do
        @params = ActionController::Parameters.new({
          org_id: {
            id: @org.id.to_s,
            name: Faker::Lorem.word,
            ror: Faker::Lorem.word
          }
        })
        @user = build(:user)

        @controller.stubs(:org_from_params).returns(build(:org))
        @controller.stubs(:remove_org_selection_params)
                   .returns({ other_param: Faker::Lorem.word })
      end

      it "returns nil if the params are not present" do
        rslt = @controller.send(:handle_org, attrs: nil)
        expect(rslt).to eql(nil)
      end
      it "returns the params if the params[:org_id] is not present" do
        rslt = @controller.send(:handle_org, attrs: {})
        expect(rslt).to eql({})
      end
      it "calls org_from_params to retrieve the Org" do
        @controller.expects(:org_from_params).at_least(1)
        rslt = @controller.send(:handle_org, attrs: @params)
      end
      it "saved the org if it was a new record" do
        count = Org.all.length
        rslt = @controller.send(:handle_org, attrs: @params)
        expect(Org.all.length).to eql(count + 1)
      end
      it "calls remove_org_selection_params" do
        @controller.expects(:org_from_params).at_least(1)
        @controller.send(:handle_org, attrs: @params)
      end
    end

  end

end
