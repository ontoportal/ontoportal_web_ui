# coding: utf-8
#
# Appliance bioportal_web_ui config
# This file should not be modified.  Most of the site related settings should be done in
# site_config.rb

# bioportal_web_ui config file for default OntoPortal appliance.

require '/srv/ontoportal/virtual_appliance/utils/hostname_lookup.rb' if File.exist?('/srv/ontoportal/virtual_appliance/utils/hostname_lookup.rb')
require_relative 'site_config.rb' if File.exist?('config/site_config.rb')

# Appliance needs to know its own address to display proper URLs
# Ideally it should be set to HOSTNAME but we fall back to using IP address if HOSTNAME is not manually set.
$REST_HOSTNAME ||= "data.industryportal.enit.fr"
$REST_PORT ||= ''
$UI_HOSTNAME ||= "industryportal.enit.fr"
$REST_URL_PREFIX ||= "http://#{$REST_HOSTNAME}/"

# Organization info
#$ORG = 'Ontoportal Appliance'
$ORG_URL ||= 'http://appliance.ontoportal.org'

# Site name (required)
$SITE ||= 'IndustryPortal'

# The URL for the BioPortal Rails UI (this application)
$UI_URL = "http://#{$UI_HOSTNAME}"

# REST core service address
$REST_URL ||= "http://#{$REST_HOSTNAME}:#{$REST_PORT}"

# URL where BioMixer GWT app is located
$BIOMIXER_URL = "http://#{$UI_HOSTNAME}/BioMixer"

# annotator proxy location.  https://github.com/sifrproject/annotators/
# annotator proxy is running on tomcat which is reverse proxied by nginx
$PROXY_URL = "#{$REST_URL}"

# If you are running a PURL server to provide URLs for ontologies in your BioPortal instance, enable this option
$PURL_ENABLED = false

# The PURL URL is generated using this prefix + the abbreviation for an ontology.
# The PURL URL generation algorithm can be altered in app/models/ontology_wrapper.rb
$PURL_PREFIX = 'http://purl.bioontology.org/ontology'

# If your BioPortal installation includes Annotator set this to false
$ANNOTATOR_DISABLED = false

# If your BioPortal installation includes Resource Index set this to false
$RESOURCE_INDEX_DISABLED = true

# Unique string representing the UI's id for use with the BioPortal Core
#$API_KEY ||= '1de0a270-29c5-4dda-b043-7c3580628cd5'
$API_KEY ||= '019adb70-1d64-41b7-8f6e-8f7e5eb54942'
# Max number of children to return when rendering a tree view
$MAX_CHILDREN = 2500

# Max number of children that it's possible to display (more than this is either too slow or not helpful to users)
$MAX_POSSIBLE_DISPLAY = 10000

# Max size allowed for uploaded files
$MAX_UPLOAD_SIZE = 1073741824

# Release version (appears in the footer)
$RELEASE_VERSION = 'OntoPortal Appliance 3.0.4'

# URL for release notes (see top-right menu item Support -> Release Notes)
$RELEASE_NOTES = 'https://www.bioontology.org/wiki/BioPortal_Virtual_Appliance_Release_Notes'

# Pairing a name with an array of ontology virtual ids will allow you to filter ontologies based on a subdomain.
# If your main UI is hosted at example.org and you add custom.example.org pointing to the same Rails installation
# you could filter the ontologies visible at custom.example.org by adding this to the hash: "custom" => { :name => "Custom Slice", :ontologies => [1032, 1054, 1099] }
# Any number of slices can be added. Groups are added automatically using the group acronym as the subdomain.
$ENABLE_SLICES = false
$ONTOLOGY_SLICES = {}

# Help page, launched from Support -> Help menu item in top navigation bar.
$WIKI_HELP_PAGE = 'https://www.bioontology.org/wiki/BioPortal_Help'

# Google Analytics ID (optional)
$ANALYTICS_ID ||= ''

# A user id for user 'anonymous' for use when a user is required for an action on the REST service but you don't want to require a user to login
$ANONYMOUS_USER = 0

# Cube metrics reporting
$ENABLE_CUBE = false

$NOT_DOWNLOADABLE = {}
# Enable client request caching
$CLIENT_REQUEST_CACHING = true

# If you don't use Airbrake you can have exceptions emailed to the $ERROR_EMAIL address by setting this to 'true'
$EMAIL_EXCEPTIONS = false

# Email settings
# ActionMailer::Base.smtp_settings = {
#   address: 'partage.enit.fr', # smtp server address, ex: smtp.example.org
#   port: 25, # smtp server port
#   domain: 'partage.enit.fr' # fqdn of rails server, ex: rails.example.org
# }

# Announcements mailman mailing list REQUEST address, EX: list-request@lists.example.org
# NOTE: You must use the REQUEST address for the mailing list. ONLY WORKS WITH MAILMAN LISTS.
$ANNOUNCE_LIST ||= 'appliance-users-request@example.org'

# Email addresses used for sending notifications (errors, feedback, support)
$SUPPORT_EMAIL ||= 'industryportal-support@enit.fr'
$ADMIN_EMAIL ||= 'industryportal-support@enit.fr'
$ERROR_EMAIL ||= 'industryportal-support@enit.fr'

# reCAPTCHA
# In order to use reCAPTCHA on the user account creation page:
#    1. Obtain a key from reCAPTCHA: http://recaptcha.net
#    2. Include the corresponding keys below (between the single quotes)
#    3. Set the USE_RECAPTCHA option to 'true'
ENV['USE_RECAPTCHA'] ||= 'false'
ENV['RECAPTCHA_PUBLIC_KEY'] ||= ''
ENV['RECAPTCHA_PRIVATE_KEY'] ||= ''

# Custom BioPortal logging
require 'log'
$REMOTE_LOGGING = false

##
# Custom Ontology Details
# Custom details can be added on a per ontology basis using a key/value pair as columns of the details table
#
# Example:
# $ADDITIONAL_ONTOLOGY_DETAILS = { 1000 => { "Additional Detail" => "Text to be shown in the right-hand column." } }
##
$ADDITIONAL_ONTOLOGY_DETAILS = {}

#Front notice appears on the front page only and is closable by the user. It remains closed for seven days (stored
$FRONT_NOTICE = ''

# Site notice appears on all pages and remains closed indefinitely. Stored below as a hash with a unique key and a
#  EX: $SITE_NOTICE = { :unique_key => 'Put your message here (can include <a href="/link">html</a> if you use
$SITE_NOTICE = {}
################################
## AUTO-GENERATED DO NOT MODIFY
#################################

# Full string for site, EX: "NCBO BioPortal"
$ORG_SITE = ($ORG.nil? || $ORG.empty?) ? $SITE : "#{$ORG} #{$SITE}"

# Email address to mail when exceptions are raised
#ExceptionNotifier.exception_recipients = [$ERROR_EMAIL]

#Fairness including config
$FAIRNESS_DISABLED = false
$FAIRNESS_URL = "http://services.industryportal.enit.fr/fair/?portal=indutryportal"
$HOSTNAME = "industryportal.enit.fr"

#Coloaboration and support
$HOME_PAGE_LOGOS = [
  {
    title: 'Supported by: OntoCommons is an H2020 CSA project dedicated to the standardisation of data documentation across all domains related to materials and manufacturing.  ',
    links: [
      {
        img_src: 'logos/supports/ontocommons-logo.png',
        url: 'https://ontocommons.eu/',
        target: '_blank',
      }
    ]
  },
  {
    title: 'With the collaboration of',
    links: [
      {
        img_src: 'logos/collaboration/enit-logo.png',
        url: 'https://www.enit.fr/',
        target: '_blank',
      },
      # {
      #   img_src: 'logos/collaboration/lgp-logo.png',
      #   url: 'https://www.lgp.enit.fr/',
      #   target: '_blank',
      # },

      {
        img_src: 'https://raw.githubusercontent.com/IndustryPortal/bioportal_web_ui/24e0ba99777d40cc97b0bfa60e73df607d58a302/app/assets/images/logos/collaboration/pics-lgp.png',
        url: 'https://github.com/PICS-LGP',
        target: '_blank',
      },
      {
        img_src: 'logos/collaboration/lirmm_logo.png',
        url: 'https://www.lirmm.fr',
        target: '_blank',
      }
    ]
  }
]

#Members
$TEAM_MEMBERS = [
  {
    name: "Hedi Karry, PhD",
    role: "",
    link: "https://fr.linkedin.com/in/hkarray",
    avatar: 'https://github.com/IndustryPortal/bioportal_web_ui/blob/master/app/assets/images/team/hedi_avatar.jpg?raw=true',
    description: "Professor in informatics",
    email: "mkarray@enit.fr",
    isEmailPro: true
  },
  {
    name: "Emna Amdouni,  PhD",
    role: "",
    link: "https://orcid.org/0000-0002-2930-5938",
    avatar: 'https://github.com/IndustryPortal/bioportal_web_ui/blob/master/app/assets/images/team/emna_avatar.jpg?raw=true',
    description: "Associate Researcher",
    email: "emna.amdouni@enit.fr",
    isEmailPro: true
  },
  {
    name: "Abdel Ouadoud Rasmi, MS",
    role: "",
    link: "https://github.com/rasmi-aw",
    avatar: 'https://github.com/IndustryPortal/bioportal_web_ui/blob/master/app/assets/images/team/abdelwadoud_avatar.jpeg?raw=true',
    description: "Software Engineer",
    email: "a.rasmi@esi-sba.dz",
    isEmailPro: true
  },
  {
    name: "Arkopaul Sarkar, PhD",
    role: "",
    link: "https://orcid.org/0000-0002-8967-7813",
    avatar: 'https://github.com/IndustryPortal/bioportal_web_ui/blob/master/app/assets/images/team/arko_avatar.jpg?raw=true',
    description: "Associate Researcher",
    email: "arkopaul.sarkar@enit.fr",
    isEmailPro: true
  },
  {
    name: "Bouchemel Nasreddine, MS",
    role: "",
    link: "https://github.com/Bouchemel-Nasreddine",
    avatar: 'https://github.com/IndustryPortal/bioportal_web_ui/blob/master/app/assets/images/team/nasreddine_avatar.jpeg?raw=true',
    description: "Software Engineer",
    email: "kn_bouchemel@esi.dz",
    isEmailPro: true
  }
]

$CONTRIBUTORS = [
  {
    full_name: "Clément Jonquet",
    position: "PhD (Senior Researcher – INRAE (MISTEA). Associate Researcher",
    works_at: "University of Montpellier (LIRMM))- France"
  },
  {
    full_name: "Syphax Bouazzouni",
    position: "Research engineer",
    works_at: "University of Montpellier (LIRMM)- France"
  },
]

#Changing app theme to make it look just like
$UI_THEME = :industryportal