class DrupalTag < ActiveRecord::Base
  attr_accessible :vid, :name, :description, :weight
  self.table_name = 'term_data'
  self.primary_key = 'tid'
  has_many :drupal_node_tag, :foreign_key => 'tid'
  has_many :drupal_node, :through => :drupal_node_tag do
    def filter_by_type(type)
      find(:all, :conditions => {:status => 1, :type => type})
    end
  end

  has_many :drupal_node_community_tag, :foreign_key => 'tid'
  has_many :drupal_node, :through => :drupal_node_community_tag do
    def filter_by_type(type)
      find(:all, :conditions => {:status => 1, :type => type})
    end
  end

  def nodes
    ids = []
    self.drupal_node_tag.each do |node_tag|
      ids << node_tag.nid
    end
    DrupalNode.find :all, :conditions => ['status = 1 AND nid IN ('+ids.uniq.join(',')+')'], :order => "nid DESC"
  end

  def self.find_nodes_by_type(tags,type,limit)
    node_ids = []
    tags.each do |tag|
      tag.drupal_node.filter_by_type(type).each do |node|
        node_ids << node.nid
      end
    end
    DrupalNode.find node_ids.uniq, :order => "created DESC", :limit => limit
  end

  def self.find_nodes_by_type_with_all_tags(tags,type,limit)
    node_ids = []
    tags.each do |tag|
      tag.drupal_node.filter_by_type(type).each do |node|
        node_ids << node.nid if (node.tags & tags).length == tags.length
      end
    end
    DrupalNode.find node_ids.uniq, :order => "nid DESC", :limit => limit
  end

  def self.find_popular_notes(tag,limit)
    tag = self.find_by_name tag
    node_ids = []
    tag.drupal_node.filter_by_type('note').each do |node|
      node_ids << node.nid if node.totalcount > 10
    end
    DrupalNode.find node_ids.uniq, :order => "created DESC", :limit => limit
  end

end
