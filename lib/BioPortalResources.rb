class BioPortalResources
    attr_accessor :base_url, :uri, :path, :params
    
    APPLICATION_ID = "4ea81d74-8960-4525-810b-fa1baab576ff"

    @@tokens = { "%ONT%" => :ontology_id, "%ONT_VIRTUAL%" => :ontology_virtual_id, "%CONC%" => :concept_id,
                 "%VIEW%" => :view_id, "%USR%" => :user_id, "%START%" => :ontology_id_start,
                 "%END%" => :ontology_id_end, "%VER1%" => :ontology_version1, "%VER2%" => :ontology_version2,
                 "%NOTE%" => :note_id, "%IND%" => :individual_id, "%PAGE_SIZE%" => :page_size,
                 "%PAGE_NUM%" => :page_number, "%SOURCE_ONT_VIRTUAL%" => :source_ontology_virtual_id,
                 "%TARGET_ONT_VIRTUAL%" => :target_ontology_virtual_id }
                 
    def initialize(params = nil)
      if params
        @params = params.clone
      end
      @uri_base_url = $REST_URL.clone
      @uri = @uri_base_url.clone
    end
    
    def generate_uri
      if @params
        @@tokens.each do |token, symbol|
          if @uri.include?(token)
            @uri.gsub!(token, CGI.escape(@params[symbol].to_s))
          end
        end
      end
      
      param_start = @uri.include?("?") ? "&" : "?"
      @uri << param_start + "applicationid=#{APPLICATION_ID}"
      
      return @uri
    end
    
    class Ontology < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/ontologies/%ONT%"
      end
    end
    
    class CreateOntology < BioPortalResources
      def initialize
        super
        @uri << "/ontologies/"
      end
    end
    
    class UpdateOntology < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/ontologies/%ONT%"
      end
    end
    
    class DownloadOntology < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/ontologies/download/%ONT%"
      end
    end
    
    class Ontologies < BioPortalResources
      def initialize
        super
        @uri << "/ontologies/"
      end
    end
    
    class ActiveOntologies < BioPortalResources
      def initialize
        super
        @uri << "/ontologies/active/"
      end
    end

    class OntologyVersions < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/ontologies/versions/%ONT_VIRTUAL%"
      end
    end

    class OntologyMetrics < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/ontologies/metrics/%ONT%"
      end
    end
    
    class Categories < BioPortalResources
      def initialize
        super
        @uri << "/categories/"
      end
    end
    
    class Groups < BioPortalResources
      def initialize
        super
        @uri << "/groups"
      end
    end
    
    class Concept < BioPortalResources
      def initialize(params, max_children = nil, light = nil)
        super(params)
        
        max_children = (max_children.nil? || max_children > $MAX_CHILDREN) ? $MAX_CHILDREN : max_children
        
        @uri << "/concepts/%ONT%/?conceptid=%CONC%"
        @uri << "&maxnumchildren=" + max_children.to_s if max_children
        @uri << "&light=1" if light
      end
    end

    class PathToRoot < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/path/%ONT%/?source=%CONC%&target=root"
      end
    end
    
    class View < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/ontologies/%VIEW%"
      end
    end
    
    class Views < BioPortalResources
      def initialize
        super
        @uri << "/views"
      end
    end
    
    class ViewVersions < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/views/versions/%ONT%"
      end
    end
    
    class LatestOntology < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/ontology/%ONT_VIRTUAL%"
      end
    end
    
    class Note < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/notes/%ONT%/?noteid=%NOTE%"
        @uri << "&threaded=true" if params[:threaded]
      end
    end
    
    class NoteVirtual < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/notes/%ONT_VIRTUAL%/?noteid=%NOTE%"
        @uri << "&threaded=true" if params[:threaded]
      end
    end
    
    class NotesForConcept < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/notes/%ONT_VIRTUAL%/?conceptid=%CONC%"
        @uri << "&threaded=true" if params[:threaded]
      end
    end

    class NotesForConceptVirtual < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/notes/%ONT_VIRTUAL%/?conceptid=%CONC%"
        @uri << "&threaded=true" if params[:threaded]
      end
    end

    class NotesForIndividual < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/notes/%ONT_VIRTUAL%/?indivudal=%IND%"
        @uri << "&threaded=true" if params[:threaded]
      end
    end

    class NotesForOntology < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/notes/%ONT%/?toplevelonly=true"
      end
    end

    class NotesForOntologyVirtual < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/notes/%ONT_VIRTUAL%?toplevelonly=true"
      end
    end

    class CreateNote < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/notes/%ONT_VIRTUAL%"
      end
    end

    class ArchiveNote < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/notes/%ONT_VIRTUAL%"
      end
    end
    
    class Users < BioPortalResources
      def initialize
        super
        @uri << "/users"
      end
    end
    
    class User < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/users/%USR%"
      end
    end
    
    class CreateUser < BioPortalResources
      def initialize
        super
        @uri << "/users/"
      end
    end
    
    class UpdateUser < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/users/%USR%"
      end
    end
    
    class Auth < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/auth?username=#{CGI.escape(params[:username])}&password=#{params[:password]}"
      end
    end
    
    class ParseOntology < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/ontologies/parse/%ONT%"
      end
    end
    
    class ParseOntologies < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/ontologies/parsebatch/%START%/%END%"
      end
    end
    
    class Diffs < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/diffs/%ONT%"
      end
    end
    
    class DownloadDiff < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/diffs/download/%VER1%/%VER2%"
      end
    end
    
    class ConceptMapping < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/mappings/concepts/%ONT_VIRTUAL%?conceptid=%CONC%&issource=true&pagesize=%PAGE_SIZE%&pagenum=%PAGE_NUM%"

        # Check for parameters and add if they exist
        @uri << "&submittedby=#{params[:user_id]}" unless params[:user_id].nil?
        @uri << "&type=#{params[:type]}" unless params[:type].nil?
        @uri << "&startdate=#{params[:start_date]}" unless params[:start_date].nil?
        @uri << "&enddate=#{params[:end_date]}" unless params[:end_date].nil?
        @uri << "&relationships=#{params[:relationships]}" unless params[:relationships].nil?
        @uri << "&sources=#{params[:sources]}" unless params[:sources].nil?
      end
    end
    
    class OntologyMapping < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/mappings/ontologies/%ONT_VIRTUAL%?issource=true&pagesize=%PAGE_SIZE%&pagenum=%PAGE_NUM%"
        
        # Check for parameters and add if they exist
        @uri << "&submittedby=#{params[:user_id]}" unless params[:user_id].nil?
        @uri << "&type=#{params[:type]}" unless params[:type].nil?
        @uri << "&startdate=#{params[:start_date]}" unless params[:start_date].nil?
        @uri << "&enddate=#{params[:end_date]}" unless params[:end_date].nil?
        @uri << "&relationships=#{params[:relationships]}" unless params[:relationships].nil?
        @uri << "&sources=#{params[:sources]}" unless params[:sources].nil?
      end
    end
    
    class BetweenOntologiesMapping < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/mappings/ontologies?sourceontology=%SOURCE_ONT_VIRTUAL%&targetontology=%TARGET_ONT_VIRTUAL%&pagesize=%PAGE_SIZE%&pagenum=%PAGE_NUM%"
        
        # Check for parameters and add if they exist
        @uri << "&unidirectional=#{params[:unidirectional]}" unless params[:unidirectional].nil?
        @uri << "&submittedby=#{params[:user_id]}" unless params[:user_id].nil?
        @uri << "&type=#{params[:type]}" unless params[:type].nil?
        @uri << "&startdate=#{params[:start_date]}" unless params[:start_date].nil?
        @uri << "&enddate=#{params[:end_date]}" unless params[:end_date].nil?
        @uri << "&relationships=#{params[:relationships]}" unless params[:relationships].nil?
        @uri << "&sources=#{params[:sources]}" unless params[:sources].nil?
      end
    end
    
    class OntologiesMappingCount < BioPortalResources
      def initialize
        super
        @uri << "/mappings/stats/ontologies"
      end
    end
    
    class BetweenOntologiesMappingCount < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/mappings/stats/ontologies/%ONT_VIRTUAL%"
      end
    end
    
    class OntologyConceptMappingCount < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/mappings/stats/ontologies/concepts/%ONT_VIRTUAL%"
        
        # Optional parameters
        @uri << "?limit=#{params[:limit]}" unless params[:limit].nil?
      end
    end
    
    class OntologyUserMappingCount < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/virtual/mappings/stats/ontologies/users/%ONT_VIRTUAL%"
      end
    end

    class Mapping < BioPortalResources
      def initialize(params)
        super(params)
        @uri << "/mappings?mappingid=#{CGI.escape(params[:mapping_id])}"
      end
    end

    class RecentMappings < BioPortalResources
      def initialize
        super
        @uri << "/mappings/stats/recent?limit=5"
      end
    end
    
    class CreateMapping < BioPortalResources
      def initialize
        super
        @uri << "/virtual/mappings/concepts"
      end
    end
    
end