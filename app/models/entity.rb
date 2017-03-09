class Entity < ActiveRecord::Base
  belongs_to :user
  has_many :annotations
  has_and_belongs_to_many :race_descriptions
  has_many :deeds
  has_many :documents, through: :annotations
  has_many :left_relationships, :class_name => "Relationship", :foreign_key => :entity_1_id
  has_many :right_relationships, :class_name => "Relationship", :foreign_key => :entity_2_id

  validates :birth_date, format: { with: /\bunknown\b|\A[cC]?(\d\d\d\d)(-\d\d)?(-\d\d)?\z/,
    message: "Bad date format.  Allowed:  2001, 2001-09, 2001-09-01" }, allow_blank: true

  validates :death_date, format: { with: /\bunknown\b|\A[cC]?(\d\d\d\d)(-\d\d)?(-\d\d)?\z/,
    message: "Bad date format.  Allowed:  2001, 2001-09, 2001-09-01" }, allow_blank: true
    
  after_save :update_tei

  module Type
  	PERSON = "person"
  	PLACE = "place"
  	ORGANIZATION = "organization"
    GEO_FEATURE = "geographic feature"
  	ALL_TYPES = [PERSON,PLACE,ORGANIZATION, GEO_FEATURE]
  	
  	REF_PREFIX = {
  	  PERSON => 'N',
  	  PLACE => 'P',
  	  ORGANIZATION => 'O',
  	  GEO_FEATURE => 'G'
  	}
  end



  module Gender
  	MALE = "male"
  	FEMALE = "female"
  	UNKNOWN = "unknown"
  	ALL_TYPES = [MALE,FEMALE,UNKNOWN]
  end

  def relationships
    left_relationships + right_relationships
  end

  def ref_id
    self[:ref_id] || Type::REF_PREFIX[entity_type] + id.to_s.rjust(8,'0')
  end

  def xml_id
    self.ref_id
  end

  def update_tei
    # build_tei_from_template
    # save tei file
  end
  
  def build_tei
    ApplicationController.new.render_to_string({:file =>     tei_template,
                                                :layout => false,
                                                :locals => { :entity => self }} )
  end
  
  def tei_template
    File.join(Rails.root, 'app', 'views', 'entities', "#{self.entity_type}_bio.xml.erb")
  end

end
