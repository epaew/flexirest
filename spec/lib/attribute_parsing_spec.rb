require 'spec_helper'

class AttributeParsingExampleBase
  include Flexirest::AttributeParsing

  def initialize(attrs={})
    @attributes = {}

    attrs.each do |attribute_name, attribute_value|
      attribute_name = attribute_name.to_sym
      @attributes[attribute_name] = parse_attribute_value(attribute_value)
    end
  end

  def method_missing(name, *_args)
    @attributes[name.to_sym]
  end

  def respond_to_missing?(method_name, _include_private = false)
    @attributes.has_key? method_name.to_sym
  end

  def test(v)
    parse_attribute_value(v)
  end
end


describe Flexirest::AttributeParsing do
  let(:subject) { AttributeParsingExampleBase.new }

  it "should parse datetimes" do
    expect(subject.test("1980-12-24T00:00:00.000Z")).to be_a(DateTime)
  end

  it "should not parse a multiline string as a datetime" do
    expect(subject.test("not a datetime\n1980-12-24T00:00:00.000Z")).to be_a(String)
  end

  it "should parse dates" do
    expect(subject.test("1980-12-24")).to be_a(Date)
  end

  it "should not parse a multiline string as a datetime" do
    expect(subject.test("not a date\n1980-12-24")).to be_a(String)
  end

  it "should return strings for string values" do
    expect(subject.test("1980-12")).to eq("1980-12")
  end

  it "should return integers for integer values" do
    expect(subject.test(1980)).to eq(1980)
  end

  it "should return floats for float values" do
    expect(subject.test(1980.12)).to eq(1980.12)
  end

  it "should return as a string a date-like string that can't be parsed" do
    expect(subject.test("7/29/2018")).to eq("7/29/2018")
  end

  it "should return AttributeParsingExampleBase for hash values" do
    expect(subject.test({ created_at: "1980-12-24" }))
      .to be_a(AttributeParsingExampleBase)
      .and have_attributes({ created_at: be_a(Date) })
  end

  it "should return AttributeParsingExampleBase for hash values in array" do
    expect(subject.test([{ created_at: "1980-12-24" }]))
      .to contain_exactly(
        be_a(AttributeParsingExampleBase).and have_attributes({ created_at: be_a(Date) })
    )
  end
end
