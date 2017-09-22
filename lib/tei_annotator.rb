class TeiAnnotator


  def initialize(transporter)
    @text_transporter = transporter
  end

  def apply_annotations(document, user)
    # grab the text of the doc
    # create a DOM from the text
    doc = load_document(document)
    # loop through the annotations for the doc
    document.applicable_annotations.each do |annotation|
      apply_annotation(doc, annotation)
    end
    # store the modified doc 
    save_document(document, doc, user)
  end  

  def load_document(document)
    text = @text_transporter.fetch(document.cwgk_id)
    Nokogiri::XML(text)
  end
  
  def save_document(document, doc, user)
    text = doc.to_xml
    @text_transporter.save(document.cwgk_id, text, user)
  end

  def apply_annotation(doc, annotation)
    paragraph = target_paragraph(doc, annotation)
    search_and_replace(doc, paragraph, annotation.verbatim, annotation.entity)
  end
  
  
  def search_and_replace(doc, paragraph, verbatim, entity)
    entity_children = []    
    paragraph.children.each do |node|
 
      md = /(.*)#{verbatim}(.*)/.match node.text
      if md && node.name != 'entity'
        # this node contains the verbatim string but has not already been marked up as an entity
        prefix = md[1]
        suffix = md[2]

        entity_node = Nokogiri::XML::Node.new(tei_element(entity), doc)
        entity_node['ref'] = entity.xml_id if entity.ref_id 
        entity_node.add_child(Nokogiri::XML::Text.new(verbatim, doc))
        
        prefix_node = Nokogiri::XML::Text.new(prefix, doc)
        node.replace(prefix_node)
        prefix_node.add_next_sibling(entity_node)
        suffix_node = Nokogiri::XML::Text.new(suffix, doc)
        entity_node.add_next_sibling(suffix_node)
      end
    end
  end
  

  TEI_TAGS = {
    Entity::Type::PERSON => 'persName',
    Entity::Type::PLACE => 'placeName',
    Entity::Type::ORGANIZATION => 'orgName',
    Entity::Type::GEO_FEATURE => 'geogName'
  }

  def tei_element(entity)
    TEI_TAGS[entity.entity_type] || 'entity'    
  end
  
  def target_paragraph(doc, annotation)
    index = target_paragraph_number(annotation.start_container) - 1 # selectors start with 1    
    doc.search('text/body/p')[index]
  end
  
  def target_paragraph_number(locator)
    md = /.*\/p\[(\d+)\].*/.match(locator)
    md.captures.first.to_i
  end
  
  
end