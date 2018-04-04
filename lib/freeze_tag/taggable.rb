require 'rails'
require 'active_record'

module FreezeTag
  module Taggable
    extend ActiveSupport::Concern
 
    included do
      has_many :freeze_tags, as: :taggable, class_name: "FreezeTag::Tag"
      has_many :active_freeze_tags, -> { where("ended_at IS NULL OR ended_at > ?", DateTime.now) }, as: :taggable, class_name: "FreezeTag::Tag"

      def freeze_tag(as: [], expire_others: false)
        as = as.is_a?(String) ? [as] : as
        as = as.map(&:downcase) if self.class.try(:freeze_tag_case_sensitive)
        
        if expire_others == true
          active_freeze_tags.where.not(tag: as).update_all(ended_at: DateTime.now)
        end

        as.each do |t|
          FreezeTag::Tag.find_or_create_by(taggable_type: self.class.name, taggable_id: self.id, tag: t)
        end
      end

      def freeze_tag_list
        active_freeze_tags.map(&:tag)
      end

      def expire_freeze_tag(tag: nil, date: nil)
        to_exp = freeze_tags.find_by(tag: tag)
        return nil unless to_exp.present?
        exp_at = date.present? ? date : DateTime.now
        to_exp.ended_at = exp_at
        to_exp.save
      end

    end
 
    module ClassMethods
      def freeze_tagged(as: nil)
        as = as.downcase if self.try(:freeze_tag_case_sensitive)
        self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND (freeze_tags.ended_at IS NULL OR freeze_tags.ended_at > '#{DateTime.now}') AND freeze_tags.tag = '#{as}'")
      end

      def previously_freeze_tagged(as: nil)
        as = as.downcase if self.try(:freeze_tag_case_sensitive)
        self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND freeze_tags.ended_at < '#{DateTime.now}' AND freeze_tags.tag = '#{as}'")
      end

      def ever_freeze_tagged(as: nil)
        as = as.downcase if self.try(:freeze_tag_case_sensitive)
        self.joins("INNER JOIN freeze_tags ON freeze_tags.taggable_id = #{self.table_name}.id AND freeze_tags.tag = '#{as}'")
      end
    end
  end
end