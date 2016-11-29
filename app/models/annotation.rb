class Annotation < ActiveRecord::Base
  belongs_to :document
  belongs_to :user
  belongs_to :entity

  def self.ingest_new_annotations
  	#  hit the hypothesis API for all group annotations ordered by most recent first
  	#  for each annotation
    annotation_list = get_recent_annotations_from_hypothesis
    annotation_list.each do |hyp_annotation|
      #  create a blank annotation
      annotation_record = Annotation.new
      # set its hypothesis_annotation_id
      annotation_record.hypothesis_annotation_id = hyp_annotation["id"]
      logger.debug("this is the annotation record ID" + annotation_record.hypothesis_annotation_id)
      # set hypothesis_user
      annotation_record.hypothesis_user = hyp_annotation["user"].gsub("acct:","")      
      # set hypothesis_date
      annotation_record.hypothesis_date = hyp_annotation["updated"]
      # set user_id to current user
      annotation_record.user_id = User.where(hypothesis_user = hyp_annotation["user"].gsub("acct:",""))
      # set verbatim
      selector = hyp_annotation["target"].first["selector"]
      exact_selection = selector.detect { |e| e["exact"] != nil }
      container_selection = selector.detect { |e| e["startContainer"] != nil }
      annotation_record.verbatim = exact_selection["exact"]
      annotation_record.prefix = exact_selection["prefix"]
      annotation_record.suffix = exact_selection["suffix"]
      annotation_record.start_container = container_selection["startContainer"]
      # set document_id to find or create the document from hash
      exact_selection = selector.detect { |e| e["value"] != nil }
      document_id = exact_selection["value"]
      document_title = hyp_annotation["document"]["title"].first
      new_doc = find_or_create_document(document_id, document_title)
      annotation_record.document_id = new_doc.id
      annotation_record.user_id = 1
      annotation_record.save
    end
  	#  else done
  end

  def self.find_or_create_document(document_id, document_title)
  	# search documents where cwgk_id = kentucky_doc_id
    #Document.create_with(title: document_title).find_or_create_by(cwgk_id: document_id)
    Document.find_or_create_by(cwgk_id: document_id) do |d|
      d.title = document_title
    end
    # if null 
  	# create a blank document where cwgk_id = kentucky_doc_id
  	# return document 
  end

  def self.request_annotations(page)
    url = 'https://hypothes.is/api/search?group=zm91G8nX&limit=200&offset=' + (page * 200).to_s
    begin
    # response = RestClient.get 'https://hypothes.is/api/search?group=zm91G8nX', {:Authorization => 'Bearer 6879-29fcc6c2d9d966889c7edd63ad14310a'}
    # response = RestClient::Request.execute(method: :get, url: 'https://hypothes.is/api/search?group=zm91G8nX&limit=200&offset=100&order=asc',
    #                        timeout: 10, headers: {:Authorization => 'Bearer 6879-29fcc6c2d9d966889c7edd63ad14310a'})
    response = RestClient::Request.execute(method: :get, url: url,
                            timeout: 10, headers: {:Authorization => 'Bearer 6879-29fcc6c2d9d966889c7edd63ad14310a'})
    rescue => e
    #e.response
    end
    jason_hash = JSON.parse(response)
    jason_hash["rows"]  # this is an array of hashes
  end

  def self.get_recent_annotations_from_hypothesis
    # return an array of hashes that were created from json
    # the below is a single annotation being processed and turned into an array of annotations.  
    # we'll need to get the list of annotations and loop through them checking dates
        # turn json into a ruby hash
    #  check date -- is it before or after most recently created annotation in our system
    recent_annotations = []
    all_annotations = []
    page = 0
    while true
      all_annotations = request_annotations(page)
      if all_annotations.empty? then return recent_annotations end
      all_annotations.each do |hyp_annotation|
        if Annotation.where(:hypothesis_annotation_id => hyp_annotation["id"]).exists? 
          return recent_annotations
        else
          recent_annotations << hyp_annotation
        end
      end
      page = page + 1
    end
  end
  
  def cwgk_id
    document.cwgk_id
  end
  
  def hypothesis_annotation
    unless defined? @hypothesis_hash
      response = RestClient::Request.execute( method: :get, 
                                              url: "https://hypothes.is/api/annotations/#{self.hypothesis_annotation_id}",
                                              timeout: 10, 
                                              headers: {:Authorization => 'Bearer 6879-29fcc6c2d9d966889c7edd63ad14310a'})
      @hypothesis_hash = JSON.parse(response)
    end
    
    @hypothesis_hash
  end
end
