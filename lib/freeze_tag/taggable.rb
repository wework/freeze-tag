require 'rails'
require 'active_record'

module FreezeTag
  module Taggable
    extend ActiveSupport::Concern
 
    included do
      has_many :freeze_tags, as: :taggable, class_name: "FreezeTag::Tag"
      has_many :active_freeze_tags, -> { where("ended_at IS NULL OR ended_at > ?", DateTime.now) }, as: :taggable, class_name: "FreezeTag::Tag"

      def freeze_tag(as: [], expire_others: false, list: nil)
        as = as.is_a?(String) ? [as] : as
        as = as.map(&:downcase) if self.class.try(:freeze_tag_case_sensitive)
        
        if expire_others == true
          active_freeze_tags.where(list: list).where.not(tag: as).update_all(ended_at: DateTime.now)
        end

        as.each do |t|
          FreezeTag::Tag.find_or_create_by(taggable_type: self.class.name, taggable_id: self.id, tag: t, list: list)
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
        to_exp.ended_at = exp_at
        to_exp.save
      end

    end
 
    module ClassMethods
      def freeze_tagged(as: nil, list: nil)
        as = as.downcase if self.try(:freeze_tag_case_sensitive)
        if list.present?
          self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND (freeze_tags.ended_at IS NULL OR freeze_tags.ended_at > '#{DateTime.now}') AND freeze_tags.tag = '#{as}' AND freeze_tags.list = '#{list}'")
        else
          self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND (freeze_tags.ended_at IS NULL OR freeze_tags.ended_at > '#{DateTime.now}') AND freeze_tags.tag = '#{as}'")
        end
      end

      def previously_freeze_tagged(as: nil, list: nil)
        as = as.downcase if self.try(:freeze_tag_case_sensitive)
        if list.present?
          self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND freeze_tags.ended_at < '#{DateTime.now}' AND freeze_tags.tag = '#{as}' AND freeze_tags.list = '#{list}'")
        else
          self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND freeze_tags.ended_at < '#{DateTime.now}' AND freeze_tags.tag = '#{as}'")
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