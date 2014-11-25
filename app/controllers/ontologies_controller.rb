class OntologiesController < ApplicationController

  require "multi_json"
  require 'cgi'

  #caches_page :index

  helper :concepts
  layout :resolve_layout

  before_filter :authorize_and_redirect, :only=>[:edit,:update,:create,:new]

  KNOWN_PAGES = Set.new(["terms", "classes", "mappings", "notes", "widgets", "summary"])
  ONTOLOGY_RANK = {"SNOMEDCT" => 1000, "NCIT" => 999, "DOID" => 998, "MEDDRA" => 997, "ICD9CM" => 996, "NDFRT" => 995, "OBI" => 994, "HP" => 993, "EFO" => 992, "MESH" => 991, "RXNORM" => 990, "FMA" => 989, "LOINC" => 988, "RADLEX" => 987, "OMIM" => 986, "EDAM" => 985, "ICD10" => 984, "CL" => 983, "ENVO" => 982, "RCD" => 981, "NCBITAXON" => 980, "NIFSTD" => 979, "PAE" => 978, "GO" => 977, "ICPC" => 976, "MA" => 975, "NDDF" => 974, "UBERON" => 973, "ABA-AMB" => 972, "PATO" => 971, "CHEBI" => 970, "COSTART" => 969, "NPO" => 968, "PW" => 967, "PSIMOD" => 966, "CPT" => 965, "BTO" => 964, "ICPC2P" => 963, "DERMLEX" => 962, "WHO-ART" => 961, "CCO" => 960, "ICD10CM" => 959, "OCRE" => 958, "PDQ" => 957, "BFO" => 956, "CLO" => 955, "PO" => 954, "MPATH" => 953, "BAO" => 952, "ICD10PCS" => 951, "AMINO-ACID" => 950, "SAO" => 949, "CTCAE" => 948, "PSDS" => 947, "PSDS" => 946, "FB-DV" => 945, "VIVO" => 944, "PPIO" => 943, "CPTH" => 942, "OntoOrpha" => 941, "AAO" => 940, "OGMD" => 939, "UO" => 938, "HL7" => 937, "ICNP" => 936, "CRISP" => 935, "VANDF" => 934, "GO-EXT" => 933, "GRO" => 932, "FAO" => 931, "ZFA" => 930, "FB-BT" => 929, "IDO" => 928, "BRO" => 927, "OGMS" => 926, "SYN" => 925, "GAZ" => 924, "IDOMAL" => 923, "OAE" => 922, "AEO" => 921, "OAE" => 920, "MS" => 919, "EPILONT" => 918, "ICF" => 917, "SO" => 916, "NBO" => 915, "MP" => 914, "NEMO" => 913, "ICD11-BODYSYSTEM" => 912, "ATO" => 911, "CPO" => 910, "CARELEX" => 909, "MDDB" => 908, "ATMO" => 907, "PR" => 906, "MEDLINEPLUS" => 905, "WB-LS" => 904, "SWO" => 903, "FDA-MEDDEVICE" => 902, "MCCL" => 901, "MO" => 900, "SNPO" => 899, "TAXRANK" => 898, "WB-PHENOTYPE" => 897, "ECO" => 896, "GRO-CPGA" => 895, "EVOC" => 894, "MAT" => 893, "CPRO" => 892, "AI-RHEUM" => 891, "CBO" => 890, "SBO" => 889, "PMA" => 888, "PAE" => 887, "BIRNLEX" => 886, "BP-METADATA" => 885, "MCBCC" => 884, "CCONT" => 883, "EMAP" => 882, "GRO-CPD" => 881, "GRO-CPGA" => 880, "OGR" => 879, "BILA" => 878, "COGAT" => 877, "COGPO" => 876, "NIFDYS" => 875, "NIFCELL" => 874, "HCPCS" => 873, "NEUMORE" => 872, "NIGO" => 871, "PEDTERM" => 870, "CNO" => 869, "SIO" => 868, "TAO" => 867, "BDO" => 866, "OMIT" => 865, "HLTHINDCTRS" => 864, "ERO" => 863, "GFO-BIO" => 862, "IAO" => 861, "HAO" => 860, "OBOREL" => 859, "VO" => 858, "OPL" => 857, "WB-BT" => 856, "TMO" => 855, "TEO" => 854, "MF" => 853, "PTO" => 852, "SPD" => 851, "ZEA" => 850, "TEDDY" => 849, "BSPO" => 848, "REX" => 847, "TOK" => 846, "CMO" => 845, "PECO" => 844, "NMR" => 843, "EP" => 842, "FBbi" => 841, "BT" => 840, "FHHO" => 839, "EHDAA" => 838, "IEV" => 837, "XAO" => 836, "RS" => 835, "SOPHARM" => 834, "BCGO" => 833, "ACGT-MO" => 832, "OGI" => 831, "PROPREO" => 830, "APO" => 829, "MAO" => 828, "AERO" => 827, "BP" => 826, "LDA" => 825, "HUGO" => 824, "VHOG" => 823, "UNITSONT" => 822, "ELIXHAUSER" => 821, "PHARE" => 820, "OMRSE" => 819, "ADW" => 818, "HPIO" => 817, "ICPS" => 816, "NEOMARK3" => 815, "TMA" => 814, "TM-CONST" => 813, "TM-OTHER-FACTORS" => 812, "IDOBRU" => 811, "SDO" => 810, "CANCO" => 809, "QIBO" => 808, "DIAGONT" => 807, "NEOMARK4" => 806, "PMR" => 805, "PSDS" => 804, "OPB" => 803, "BIOMODELS" => 802, "SPTO" => 801, "SOY" => 800, "TTO" => 799, "WSIO" => 798, "FYPO" => 797, "YPO" => 796, "GEOSPECIES" => 795, "PTRANS" => 794, "CARO" => 793, "EXO" => 792, "VT" => 791, "ONTODM-CORE" => 790, "OOEVV" => 789, "SEP" => 788, "CTONT" => 787, "LIPRO" => 786, "EHDAA2" => 785, "FB-SP" => 784, "MIRO" => 783, "FLU" => 782, "NATPRO" => 781, "ECG" => 780, "CHEMINF" => 779, "GRO-CPGA" => 778, "SITBAC" => 777, "SPO" => 776, "CDAO" => 775, "XCO" => 774, "TGMA" => 773, "TADS" => 772, "PRO-ONT" => 771, "BHO" => 770, "GALEN" => 769, "CPTAC" => 768, "EHDA" => 767, "MHC" => 766, "OGDI" => 765, "MFO" => 764, "IMR" => 763, "pseudo" => 762, "DC-CL" => 761, "FB-CV" => 760, "LHN" => 759, "HOM" => 758, "DDANAT" => 757, "KISAO" => 756, "DIKB" => 755, "SSO" => 754, "CAO" => 753, "OBOE-SBC" => 752, "DDI" => 751, "PEO" => 750, "PHYFIELD" => 749, "ROLEO" => 748, "SBRO" => 747, "RPO" => 746, "ONTODT" => 745, "RNAO" => 744, "MEGO" => 743, "ICECI" => 742, "PHYLONT" => 741, "MFOEM" => 740, "INO" => 739, "GFO" => 738, "TM-SIGNS-AND-SYMPTS" => 737, "PVONTO" => 736, "REPO" => 735, "SHR" => 734, "CHEMBIO" => 733, "TM-MER" => 732, "JERM" => 731, "MMO" => 730, "CO-WHEAT" => 729, "IMGT-ONTOLOGY" => 728, "IXNO" => 727, "PLATSTG" => 726, "PHENX" => 725, "CTX" => 724, "MIXSCV" => 723, "NONRCTO" => 722, "RCTONT" => 721, "ONTOMA" => 720, "NIFSUBCELL" => 719, "IDOBRU" => 718, "VSO" => 717, "OBIWS" => 716, "MDCDRG" => 715, "LSM" => 714, "ONSTR" => 713, "RH-MESH" => 712, "I2B2-PATVISDIM" => 711, "EMO" => 710, "HOMERUN" => 709, "DWC-TEST" => 708, "CPT-KM" => 707, "CLINIC" => 706, "ATC" => 705, "GCC" => 704, "DEMOGRAPH" => 703, "UCSFEPIC" => 702, "ICD9CM-KM" => 701, "UCSFICU" => 700, "MEDABBS" => 699, "USSOC" => 698, "UCSFORTHO" => 697, "OSHPD" => 696, "HOM-TEST" => 695, "UCSFXPLANT" => 694, "EPICMEDS" => 693, "ICDO3" => 692, "PCO" => 691, "CONSENT-ONT" => 690, "PROVO" => 689, "NHDS" => 688, "CMS" => 687, "NTDO" => 686, "ONTOKBCF" => 685, "GENETRIAL" => 684, "SWEET" => 683, "GLOB" => 682, "GLYCO" => 681, "QUDT" => 680, "ONTODM-KDD" => 679, "IMMDIS" => 678, "BRIDG" => 677, "GEXO" => 676, "REXO" => 675, "RETO" => 674, "CLIN-EVAL" => 673, "VSAO" => 672, "MIRNAO" => 671, "FIX" => 670, "SYMP" => 669, "VARIO"  => 668}.freeze

  # GET /ontologies
  # GET /ontologies.xml
  def index
    @ontologies = LinkedData::Client::Models::Ontology.all(include: LinkedData::Client::Models::Ontology.include_params)
    @submissions = LinkedData::Client::Models::OntologySubmission.all
    @submissions_map = Hash[@submissions.map {|sub| [sub.ontology.acronym, sub] }]
    @categories = LinkedData::Client::Models::Category.all
    @groups = LinkedData::Client::Models::Group.all

    # Count the number of classes in each ontology
    metrics_hash = get_metrics_hash
    @class_counts = {}
    @ontologies.each do |o|
      @class_counts[o.id] = metrics_hash[o.id].classes if metrics_hash[o.id]
      @class_counts[o.id] ||= 0
    end

    @mapping_counts = {}
    @note_counts = {}
    respond_to do |format|
      format.html # index.rhtml
    end
  end

  include ActionView::Helpers::NumberHelper
  def browse
    @app_name = "FacetedBrowsing"
    @app_dir = "/browse"
    @base_path = @app_dir
    @ontologies = LinkedData::Client::Models::Ontology.all(include: LinkedData::Client::Models::Ontology.include_params + ",viewOf", include_views: true)
    ontologies_hash = Hash[@ontologies.map {|o| [o.id, o] }]
    @admin = session[:user] ? session[:user].admin? : false
    @development = Rails.env.development?

    submissions = LinkedData::Client::Models::OntologySubmission.all(include_views: true)
    submissions_map = Hash[submissions.map {|sub| [sub.ontology.acronym, sub] }]

    @categories = LinkedData::Client::Models::Category.all
    @categories_hash = Hash[@categories.map {|c| [c.id, c] }]

    @groups = LinkedData::Client::Models::Group.all
    @groups_hash = Hash[@groups.map {|g| [g.id, g] }]


    reviews = {}
    LinkedData::Client::Models::Review.all.each do |r|
      reviews[r.reviewedOntology] ||= []
      reviews[r.reviewedOntology] << r
    end

    metrics_hash = get_metrics_hash

    @formats = Set.new

    @ontologies.each do |o|
      if metrics_hash[o.id]
        o.class_count = metrics_hash[o.id].classes
      else
        o.class_count = 0
      end
      o.class_count_formatted = number_with_delimiter(o.class_count, :delimiter => ",")

      o.type          = o.viewOf.nil? ? "ontology" : "ontology_view"
      o.show          = o.viewOf.nil? ? true : false # show ontologies only by default
      o.reviews       = reviews[o.id] || []
      o.groups        = o.group || []
      o.categories    = o.hasDomain || []
      o.note_count    = o.notes.length
      o.review_count  = o.reviews.length
      o.project_count = o.projects.length
      o.private       = o.private?
      o.viewOfOnt     = ontologies_hash[o.viewOf]

      o.artifacts = []
      o.artifacts << "notes" if o.notes.length > 0
      o.artifacts << "reviews" if o.reviews.length > 0
      o.artifacts << "projects" if o.projects.length > 0
      o.artifacts << "summary_only" if o.summaryOnly

      o.popularity = ONTOLOGY_RANK[o.acronym] || 0

      o.submission = submissions_map[o.acronym]
      next unless o.submission

      o.format = o.submission.hasOntologyLanguage
      @formats << o.submission.hasOntologyLanguage
    end
  end

  # GET /visualize/:ontology
  def classes
    # Hack to make ontologyid and conceptid work in addition to id and ontology params
    params[:id] = params[:id].nil? ? params[:ontologyid] : params[:id]
    params[:ontology] = params[:ontology].nil? ? params[:id] : params[:ontology]
    # Set the ontology we are viewing
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    # Get the latest 'ready' submission, or fallback to any latest submission
    @submission = get_ontology_submission_ready(@ontology)  # application_controller

    get_class(params)   # application_controller::get_class

    if request.accept.to_s.eql?("application/ld+json") || request.accept.to_s.eql?("application/json")
      headers['Content-Type'] = request.accept.to_s
      render text: @concept.to_jsonld
      return
    end

    # set the current PURL for this class
    @current_purl = @concept.purl if $PURL_ENABLED

    begin
      @mappings = @concept.explore.mappings
    rescue Exception => e
      msg = ''
      if @concept.instance_of?(LinkedData::Client::Models::Class) &&
          @ontology.instance_of?(LinkedData::Client::Models::Ontology)
        msg = "Failed to explore mappings for #{@concept.id} in #{@ontology.id}"
      end
      LOG.add :error, msg + "\n" + e.message
      @mappings = []
    end
    @delete_mapping_permission = check_delete_mapping_permission(@mappings)

    begin
      @notes = @concept.explore.notes
    rescue Exception => e
      msg = ''
      if @concept.instance_of?(LinkedData::Client::Models::Class) &&
          @ontology.instance_of?(LinkedData::Client::Models::Ontology)
        msg = "Failed to explore notes for #{@concept.id} in #{@ontology.id}"
      end
      LOG.add :error, msg + "\n" + e.message
      @notes = []
    end

    unless @concept.id.to_s.empty?
      # Update the tab with the current concept
      update_tab(@ontology,@concept.id)
    end
    if request.xhr?
      return render 'visualize', :layout => false
    else
      return render 'visualize', :layout => "ontology_viewer"
    end
  end

  def create
    if params['commit'] == 'Cancel'
      redirect_to "/ontologies"
      return
    end
    @ontology = LinkedData::Client::Models::Ontology.new(values: params[:ontology])
    @ontology_saved = @ontology.save
    if !@ontology_saved || @ontology_saved.errors
      @categories = LinkedData::Client::Models::Category.all
      @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
      @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
      @errors = response_errors(@ontology_saved)
      #@errors = {acronym: "Acronym already exists, please use another"} if @ontology_saved.status == 409
      render "new"
    else
      # TODO_REV: Enable subscriptions
      # if params["ontology"]["subscribe_notifications"].eql?("1")
      #  DataAccess.createUserSubscriptions(@ontology.administeredBy, @ontology.ontologyId, NOTIFICATION_TYPES[:all])
      # end
      if @ontology_saved.summaryOnly
        redirect_to "/ontologies/success/#{@ontology.acronym}"
      else
        redirect_to new_ontology_submission_url(CGI.escape(@ontology_saved.id))
      end
    end
  end

  def edit
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    redirect_to_home unless session[:user] && @ontology.administeredBy.include?(session[:user].id) || session[:user].admin?
    @categories = LinkedData::Client::Models::Category.all
    @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
    @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
  end

  def mappings
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    counts = LinkedData::Client::HTTP.get("#{LinkedData::Client.settings.rest_url}/mappings/statistics/ontologies/#{params[:id]}")
    @ontologies_mapping_count = []
    unless counts.nil?
      counts.members.each do |acronym|
        count = counts[acronym]
        # Note: find_by_acronym includes ontology views
        ontology = LinkedData::Client::Models::Ontology.find_by_acronym(acronym.to_s).first
        next unless ontology
        @ontologies_mapping_count << {'ontology' => ontology, 'count' => count}
      end
      @ontologies_mapping_count.sort! {|a,b| a['ontology'].name.downcase <=> b['ontology'].name.downcase } unless @ontologies_mapping_count.nil? || @ontologies_mapping_count.length == 0
    end
    @ontology_id = @ontology.acronym
    @ontology_label = @ontology.name
    if request.xhr?
      render :partial => 'mappings', :layout => false
    else
      render :partial => 'mappings', :layout => "ontology_viewer"
    end
  end

  def new
    if (params[:id].nil?)
      @ontology = LinkedData::Client::Models::Ontology.new(values: params[:ontology])
      @ontology.administeredBy = [session[:user].id]
    else
      # Note: find_by_acronym includes ontology views
      @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    end
    @categories = LinkedData::Client::Models::Category.all
    @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
    @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
  end

  def notes
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    # Get the latest 'ready' submission, or fallback to any latest submission
    @submission = get_ontology_submission_ready(@ontology)  # application_controller
    @notes = @ontology.explore.notes
    @notes_deletable = false
    # TODO_REV: Handle notes deletion
    # @notes.each {|n| @notes_deletable = true if n.deletable?(session[:user])} if @notes.kind_of?(Array)
    @note_link = "/ontologies/#{@ontology.acronym}/notes/"
    if request.xhr?
      render :partial => 'notes', :layout => false
    else
      render :partial => 'notes', :layout => "ontology_viewer"
    end
  end

  # GET /ontologies/1
  # GET /ontologies/1.xml
  def show
    # Hack to make ontologyid and conceptid work in addition to id and ontology params
    params[:id] = params[:id].nil? ? params[:ontologyid] : params[:id]
    params[:ontology] = params[:ontology].nil? ? params[:id] : params[:ontology]

    # PURL-specific redirect to handle /ontologies/{ACR}/{CLASS_ID} paths
    if params[:purl_conceptid]
      if params[:conceptid]
        params.delete(:purl_conceptid)
      else
        params[:conceptid] = params.delete(:purl_conceptid)
      end
      redirect_to "/ontologies/#{params[:acronym]}?p=classes#{params_string_for_redirect(params, prefix: "&")}", :status => :moved_permanently
      return
    end

    if params[:ontology].to_i > 0
      acronym = BPIDResolver.id_to_acronym(params[:ontology])
      if acronym
        redirect_new_api
        return
      end
    end

    # Fix parameters to only use known pages
    params[:p] = nil unless KNOWN_PAGES.include?(params[:p])

    # This action is now a router using the 'p' parameter as the page to show
    case params[:p]
      when "terms"
        params[:p] = 'classes'
        redirect_to "/ontologies/#{params[:ontology]}#{params_string_for_redirect(params)}", :status => :moved_permanently
        return
      when "classes"
        self.classes #rescue self.summary
        return
      when "mappings"
        self.mappings #rescue self.summary
        return
      when "notes"
        self.notes #rescue self.summary
        return
      when "widgets"
        self.widgets #rescue self.summary
        return
      when "summary"
        self.summary
        return
      else
        self.summary
        return
    end
  end

  def submit_success
    @acronym = params[:id]
    # Force the list of ontologies to be fresh by adding a param with current time
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id], cache_invalidate: Time.now.to_i).first
    render :partial => "submit_success", :layout => "ontology"
  end

  def summary
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    raise Error404 if @ontology.nil?
    # Check to see if user is requesting RDF+XML, return the file from REST service if so
    if request.accept.to_s.eql?("application/ld+json") || request.accept.to_s.eql?("application/json")
      headers['Content-Type'] = request.accept.to_s
      render text: @ontology.to_jsonld
      return
    end
    # Explore the ontology links
    @metrics = @ontology.explore.metrics rescue []
    @reviews = @ontology.explore.reviews.sort {|a,b| b.created <=> a.created} || []
    @projects = @ontology.explore.projects.sort {|a,b| a.name.downcase <=> b.name.downcase } || []
    # retrieve submissions in descending submissionId order, should be reverse chronological order.
    @submissions = @ontology.explore.submissions.sort {|a,b| b.submissionId <=> a.submissionId } || []
    LOG.add :error, "No submissions for ontology: #{@ontology.id}" if @submissions.empty?
    # Get the latest submission, not necessarily the latest 'ready' submission
    @submission_latest = @ontology.explore.latest_submission rescue @ontology.explore.latest_submission(include: "")
    @views = @ontology.explore.views.sort {|a,b| a.acronym.downcase <=> b.acronym.downcase } || []
    if request.xhr?
      render :partial => 'metadata', :layout => false
    else
      render :partial => 'metadata', :layout => "ontology_viewer"
    end
  end

  def update
    if params['commit'] == 'Cancel'
      acronym = params['id']
      redirect_to "/ontologies/#{acronym}"
      return
    end
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology][:acronym] || params[:id]).first
    @ontology.update_from_params(params[:ontology])
    error_response = @ontology.update
    if error_response
      @categories = LinkedData::Client::Models::Category.all
      @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
      @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
      @errors = response_errors(error_response)
      @errors = {acronym: "Acronym already exists, please use another"} if error_response.status == 409
    else
      # TODO_REV: Enable subscriptions
      # if params["ontology"]["subscribe_notifications"].eql?("1")
      #  DataAccess.createUserSubscriptions(@ontology.administeredBy, @ontology.ontologyId, NOTIFICATION_TYPES[:all])
      # end
      redirect_to "/ontologies/#{@ontology.acronym}"
    end
  end

  def virtual
    redirect_new_api
  end

  def visualize
    redirect_new_api(true)
  end

  def widgets
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    if request.xhr?
      render :partial => 'widgets', :layout => false
    else
      render :partial => 'widgets', :layout => "ontology_viewer"
    end
  end

  private

  def resolve_layout
    case action_name
    when 'browse'
      'angular'
    else
      'ontology'
    end
  end

end
