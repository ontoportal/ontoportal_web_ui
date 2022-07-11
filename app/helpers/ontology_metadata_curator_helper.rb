module OntologyMetadataCuratorHelper
  def metadata_for_select
    get_metadata
    return @metadata_for_select
  end 

  def get_metadata
    @metadata_for_select = []
    submission_metadata.each do |data|
      @metadata_for_select << data["attribute"]
    end
    @metadata_for_select.sort! 
  end   
end 
