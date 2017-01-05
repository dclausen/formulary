require_relative "spec_helper"

class TestForm
  include Formulary::Form

  def initialize
    attribute :first_name, :text, {}, presence: true
    attribute :last_name, :text, {}, presence: true
  end

  def action
    "/test"
  end

  def method
    "POST"
  end
end

RSpec.describe Formulary do
  subject { TestForm.new }

  it "#attribute is set" do
    subject.first_name = "John"
    expect(subject.first_name).to eq("John")
  end

  it "#attribute presence is validated" do
    expect(subject.valid?).to be false
    subject.first_name = "John"
    expect(subject.valid?).to be false
    subject.last_name = "Doe"
    expect(subject.valid?).to be true
  end

  it "#name works" do
    expect(subject.name).to eq("test")
  end

  it "#action works" do
    expect(subject.action).to eq("/test")
  end

  it "#method works" do
    expect(subject.method).to eq("POST")
  end

  describe "serialization" do
    it "#to_json exports to string" do
      expect(subject.to_json).to eq(%q/[{"name":"first_name","type":"text","options":{},"validations":{"presence":true}},{"name":"last_name","type":"text","options":{},"validations":{"presence":true}}]/)
    end

    it "#from_json imports model as string" do
      form = TestForm.new
      serialized_json = %q/[{"name":"first_name","type":"text","options":{},"validations":{"presence":true}},{"name":"middle_name","type":"text","options":{},"validations":{"presence":false}},{"name":"last_name","type":"text","options":{},"validations":{"presence":true}}]/

      expect{ form.middle_name }.to raise_error(NoMethodError)
      form.from_json(serialized_json)
      expect{ form.middle_name }.not_to raise_error
    end
  end

  describe "#render" do
    describe "bootstrap3" do
      describe "html output displaying properly" do
        it "form" do
          [
            %r{^<form name="test"},
          ].each {|regexp| expect(subject.render).to match(regexp) }
        end

        it "text" do
          [
            %r{<div.+><label for="first_name">First name</label><input type="text".+/></div>},
            %r{<div.+><label for="last_name">Last name</label><input type="text".+/></div>},
          ].each {|regexp| expect(subject.render).to match(regexp) }
        end

        it "textarea" do
          subject.attribute :life_story, :textarea, { content: "hmm, yay"}, presence: false
          [
            %r{<textarea .+name="life_story">\nhmm, yay</textarea>}m,
          ].each {|regexp| expect(subject.render).to match(regexp) }
        end

        it "select" do
          subject.attribute :gender, :select, { options: ["Male", "Female"] }, presence: false
          [
            %r{<select .+name="gender">\n<option>Male</option><option>Female</option></select>}m,
          ].each {|regexp| expect(subject.render).to match(regexp) }
        end
      end
    end
  end
end
