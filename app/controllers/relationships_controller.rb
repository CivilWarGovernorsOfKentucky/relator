class RelationshipsController < ApplicationController
  before_action :set_relationship, only: [:show, :edit, :update, :destroy]

  # GET /relationships
  # GET /relationships.json
  def index
    @relationships = Relationship.all
  end

  # GET /relationships/1
  # GET /relationships/1.json
  def show
  end

  # GET /relationships/new
  def new
    @relationship = Relationship.new
  end

  # GET /relationships/1/edit
  def edit
  end

  # POST /relationships
  # POST /relationships.json
  def create
    #@relationship = Relationship.new(relationship_params)

    respond_to do |format|
      if @relationship.save
        format.html { redirect_to @relationship, notice: 'Relationship was successfully created.' }
        format.json { render :show, status: :created, location: @relationship }
      else
        format.html { render :new }
        format.json { render json: @relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  def define
    @entities = []
    @relationships = []
    #get document by the cwgkid
    #get the annotations for that doc
    document = Document.where(:cwgk_id => params[:cwgk_id]).first
    Annotation.where(:document_id => document.id).each do |annotation|
      #get the entities for the annotations for the doc
      @entities << annotation.entity unless annotation.entity.nil?
    end
    @relationships = Relationship.where document_id: document.id
    #pass to the view to show the entities with a checkbox next to them
    @entities
    @cwgk_id = params[:cwgk_id]
  end

  def add
    document = Document.find_by cwgk_id: params[:cwgk_id]
    params[:left_entity].each do |left|
        params[:right_entity].each do |right|
          next if left == right
          @relationship = Relationship.new
          @relationship.entity_1_id = left
          @relationship.entity_2_id = right
          @relationship.relationship_type = params[:relationship_type]
          @relationship.user_id = current_user.id
          @relationship.citation = params[:citation]
          @relationship.document_id = document.id
          @relationship.save!
          record_deed(Deed::RELATIONSHIP_CREATE, document)
        end
      end
    redirect_to define_relationships_path(params[:cwgk_id])
  end

  # PATCH/PUT /relationships/1
  # PATCH/PUT /relationships/1.json
  def update
    respond_to do |format|
      if @relationship.update(relationship_params)
        record_deed(Deed::RELATIONSHIP_EDIT)
        format.html { redirect_to @relationship, notice: 'Relationship was successfully updated.' }
        format.json { render :show, status: :ok, location: @relationship }
      else
        format.html { render :edit }
        format.json { render json: @relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /relationships/1
  # DELETE /relationships/1.json
  def destroy
    if @relationship.document_id
      document = Document.find(@relationship.document_id).cwgk_id
    else
      document = nil
    end
    deeds = Deed.where(relationship: @relationship)
    deeds.each do |d|
      d.destroy
    end
    @relationship.destroy
    respond_to do |format|
      if !document.nil?
        format.html { redirect_to define_relationships_path(document) }
        format.json { head :no_content }
      else
        format.html { redirect_to relationships_url, notice: 'Relationship was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  def record_deed(deed_type, document)
    deed = Deed.new
    deed.relationship = @relationship
    deed.deed_type = deed_type
    deed.user = current_user
    deed.document_id = document.id
    deed.save!
  end

  private
    def get_relationships_for_entities
      @relationships = []
      @entities.each do |entity| 
          Relationship.where(:entity_1_id => entity.id).each do |relationship|
            if (@entities.include?(relationship.entity_2)) then 
              @relationships << relationship
            end
          end
      end
      @entities.each do |entity| 
          Relationship.where(:entity_2_id => entity.id).each do |relationship|
            if (@entities.include?(relationship.entity_1)) then 
              @relationships << relationship
            end
          end
      end
      # something here to remove relationships where the entity2 isn't in our list of entities or smarter code above
      @relationships = @relationships.uniq
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_relationship
      @relationship = Relationship.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def relationship_params
      params.require(:relationship).permit(:entity_1_id, :entity_2_id, :relationship_type, :user_id, :citation)
    end
end
