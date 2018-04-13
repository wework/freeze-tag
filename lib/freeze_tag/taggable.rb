require 'rails'
require 'active_record'

module FreezeTag
  module Taggable
    extend ActiveSupport::Concern
 
    included do
      has_many :freeze_tags, as: :taggable, class_name: "FreezeTag::Tag"
      has_many :active_freeze_tags, -> { where("expired_at IS NULL OR expired_at > ?", DateTime.now) }, as: :taggable, class_name: "FreezeTag::Tag"

      attr_accessor :freeze_tagged
      after_commit -> { create_freeze_tags_from_attr_accessor(validate: false) }
      before_validation -> { create_freeze_tags_from_attr_accessor(validate: true) } 

      def create_freeze_tags_from_attr_accessor(validate: false)
        return unless self.freeze_tagged.present?
        self.freeze_tagged.to_a.each do |ft|
          self.freeze_tag(as: ft[:as], expire_others: ft[:expire_others].present?, list: ft[:list], validate: validate)
        end
      end

      def freeze_tag(as: [], expire_others: false, list: nil, validate: false)
        ActiveRecord::Base.transaction do
          as = as.is_a?(String) ? [as] : as
          as = as.map(&:downcase) if self.class.try(:freeze_tag_case_sensitive)
          
          if expire_others == true
            active_freeze_tags.where(list: list).where.not(tag: as).update_all(expired_at: DateTime.now)
          end

          unless as.present?
            self.errors.add(:freeze_tags, "Missing Tags")
            return
          end

          as.each do |t|
            if validate == false
              ft = FreezeTag::Tag.find_or_create_by(taggable_type: self.class.name, taggable_id: self.id, tag: t, list: list, expired_at: nil)
            else
              ft = FreezeTag::Tag.find_or_initialize_by(taggable_type: self.class.name, taggable_id: self.id, tag: t, list: list, expired_at: nil)
              unless ft.valid?
                self.errors.add(:freeze_tags, "Freeze tag error #{ft.errors}")
              end
            end
          end
        end
      end

      def freeze_tag_list(list: nil, only_active: true)
        base = only_active ? active_freeze_tags : freeze_tags
        if list.present?
          base = base.where(list: list)
        end
        base.map(&:tag)
      end

      def expire_freeze_tag(tag: nil, date: nil, list: nil)
        tag = tag.downcase if self.try(:freeze_tag_case_sensitive)
        to_exp = freeze_tags.find_by(tag: tag, list: list)
        return nil unless to_exp.present?
        exp_at = date.present? ? date : DateTime.now
        to_exp.expired_at = exp_at
        to_exp.save
      end

    end
 
    module ClassMethods
      def freeze_tagged(as: nil, list: nil)
        as = as.downcase if self.try(:freeze_tag_case_sensitive)
        if list.present?
          self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND (freeze_tags.expired_at IS NULL OR freeze_tags.expired_at > '#{DateTime.now}') AND freeze_tags.tag = '#{as}' AND freeze_tags.list = '#{list}'")
        else
          self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND (freeze_tags.expired_at IS NULL OR freeze_tags.expired_at > '#{DateTime.now}') AND freeze_tags.tag = '#{as}'")
        end
      end

      def previously_freeze_tagged(as: nil, list: nil)
        as = as.downcase if self.try(:freeze_tag_case_sensitive)
        if list.present?
          self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND freeze_tags.expired_at < '#{DateTime.now}' AND freeze_tags.tag = '#{as}' AND freeze_tags.list = '#{list}'")
        else
          self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND freeze_tags.expired_at < '#{DateTime.now}' AND freeze_tags.tag = '#{as}'")
        end
      end

      def ever_freeze_tagged(as: nil, list: nil)
        as = as.downcase if self.try(:freeze_tag_case_sensitive)
        if list.present?
          self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND freeze_tags.tag = '#{as}' AND freeze_tags.list = '#{list}'")
        else
          self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND freeze_tags.tag = '#{as}'")
        end
      end
    end
  end
end