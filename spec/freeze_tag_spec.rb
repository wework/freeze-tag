require 'spec_helper'

RSpec.describe FreezeTag do
  let!(:article) { Article.create }
  let!(:article1) { Article.create }
  let!(:article2) { Article.create }

  it "has a version number" do
    expect(FreezeTag::VERSION).not_to be nil
  end

  it "allows tags to be present on a model" do
    expect(article).to respond_to(:freeze_tags)
  end

  it "allows you to tag an article" do
    expect{ article.freeze_tag(as: "Cool") }.to change{FreezeTag::Tag.count}.by(1)
  end

  it "allows you to tag an article with a list" do
    expect{ article.freeze_tag(as: "Cool", list: "Ideas") }.to change{FreezeTag::Tag.where(list: "Ideas").count}.by(1)
  end

  it "applies the tag to article" do
    article.freeze_tag(as: "Cool")
    expect(article.freeze_tags.count).to eq(1)
  end

  it "doesn't allow multiple tags with the same value on the same list" do
    article.freeze_tag(as: "Same")
    expect{ article.freeze_tag(as: "Same") }.to change{FreezeTag::Tag.count}.by(0)
  end

  it "allows multiple tags with the same value if they are on different lists" do
    article.freeze_tag(as: "Same", list: "Ideas")
    expect{ article.freeze_tag(as: "Same", list: "Stuff") }.to change{FreezeTag::Tag.count}.by(1)
  end

  it "expires all the other tags" do
    article.freeze_tag(as: "Old")
    article.freeze_tag(as: "Old2")
    article.freeze_tag(as: ["Old3", "Old4"])
    article.freeze_tag(as: ["New", "Old"], expire_others: true)
    article.reload
    expect(article.active_freeze_tags.count).to eq(2)
  end

  it "expires only the other tags on the list passed in" do
    article.freeze_tag(as: "Old", list: "Ideas")
    article.freeze_tag(as: "Old2", list: "Stuff")
    article.freeze_tag(as: ["Old3", "Old4"], list: "Ideas")
    article.freeze_tag(as: ["New", "Old"], expire_others: true, list: "Ideas")
    article.reload
    expect(article.active_freeze_tags.count).to eq(3)
  end

  it "converts all tags to lowercase if the option is configured" do
    allow(Article).to receive(:freeze_tag_case_sensitive).and_return(true)
    article.freeze_tag(as: "Cool")
    expect(article.freeze_tags.first.tag).to eq("cool")
  end

  it "doesn't convert all tags to lowercase if the option is configured" do
    article.freeze_tag(as: "Cool")
    expect(article.freeze_tags.first.tag).to eq("Cool")
  end

  it "returns an array of simple tag names" do
    article.freeze_tag(as: "Cool")
    article.freeze_tag(as: "Coolio")
    article.freeze_tag(as: "Weird Al")
    article.expire_freeze_tag(tag: "Weird Al", date: (DateTime.now-30.days))
    expect(article.freeze_tag_list).to eq(["Cool", "Coolio"])
  end

  it "returns an array of simple tag names based on the list you pass" do
    article.freeze_tag(as: "Cool", list: "Ideas")
    article.freeze_tag(as: "Coolio", list: "Ideas")
    article.freeze_tag(as: "Weird Al", list: "Stuff")
    expect(article.freeze_tag_list(list: "Ideas")).to eq(["Cool", "Coolio"])
  end

  it "allows for a tag to be expired" do
    article.freeze_tag(as: "Cool")
    article.expire_freeze_tag(tag: "Cool")
    expect(article.freeze_tags.first.ended_at).to be_truthy
  end

  it "allows for a tag to be expired by list" do
    article.freeze_tag(as: "Cool", list: "Ideas")
    article.freeze_tag(as: "Cool", list: "Stuff")
    article.expire_freeze_tag(tag: "Cool", list: "Ideas")
    article.reload
    expect(article.freeze_tag_list).to eq(["Cool"])
    expect(article.freeze_tag_list(list: "Ideas")).to eq([])
    expect(article.freeze_tag_list(list: "Stuff")).to eq(["Cool"])
  end

  it "retrieves all the articles tagged as cool" do
    article.freeze_tag(as: "Cool")
    article1.freeze_tag(as: "Cool")
    article2.freeze_tag(as: "UnCool")
    expect(Article.freeze_tagged(as: "Cool").count).to eq(2)
  end

end
