# OntoPortal BioMixer Visualizer

This directory vendors the built-in copy of the maintained [OntoPortal BioMixer Visualizer](https://github.com/ontoportal/biomixer-visualizer). The new standalone repository is the source of truth; it replaces the legacy BioMixer project rather than continuing that project's history.

The dependency-light HTML, CSS, and JavaScript can be served directly by Rails from `public/biomixer-visualizer` without a Node build step.

## Supported embed parameters

The app accepts the legacy BioMixer parameters so existing `/ajax/biomixer` links continue to work:

- `mode=embed`
- `embed_mode=paths_to_root | term_neighborhood | mappings_neighborhood | ontology_mapping_overview | uml | diagram | print`
- `ontology_acronym` / `ontology` / `acronym`
- `full_concept_id` / `conceptid` / `class_id`
- `userapikey` / `apikey`
- `restURLPrefix`

Additional optional parameters:

- `sparql_endpoint` / `sparqlEndpoint` / `sparql` — pre-fills the SPARQL endpoint used by the selection builder.
- `lodview_url` / `lodview` / `resource_view_url` — optional resource-page template. Use `{iri}` if the target URL expects an encoded IRI placeholder.

## Main features

- Paths-to-root, term neighborhood, mapping neighborhood, ontology mapping overview, whole-ontology Atlas, and UML/printable selection modes.
- Pure SVG renderer with pan, zoom, zoom buttons, node dragging, fit-to-screen, draggable minimap viewport, keyboard shortcuts/help overlay, and fullscreen messaging compatible with the old BioMixer iframe contract.
- Search/jump-to-class using the OntoPortal `/search` endpoint, including jump-and-focus inside the Atlas map.
- Parent, child, and mapping expansion from the selected node.
- Details panel with definition, synonyms, IRI copy, selected-node JSON copy, API-record opening, ontology context, and visible relations.
- Selection studio for building curated printable subsets from the selected node, connected nodes, the visible graph, or SPARQL results.
- SPARQL selection builder with templates for focus-class neighborhood, children, parents, and resource triples. SELECT results are converted into a UML subset when class/resource IRIs are detected.
- LodView-inspired resource view that shows compact facts/triples for the selected node and can populate additional facts through SPARQL.
- Edge filters, multiple layouts, selection history, and SVG/PNG/JSON/draw.io/PlantUML export.
- Print-optimized A4 landscape CSS for diagram views.
- Node limiting with overflow clustering, a visible-node budget slider, raw/display graph separation, hidden-node reporting, and page-by-page Atlas loading to keep very large ontologies responsive.
- Light/dark theme toggle, map-reading guidance, and graph legend for a polished OntoPortal/OntoPanel feel.

## Integration

The Rails partial `app/views/concepts/_biomixer` and the public widget at `/widgets/visualization/` keep the legacy BioMixer embed by default. They switch to this app only when the `biomixer_replacement` Flipper feature is enabled.

The vendored copy is served from `/biomixer-visualizer` on the same UI host unless the standalone deployment is configured with:

```ruby
$ONTOPANEL_VISUALIZER_URL = ENV["ONTOPANEL_VISUALIZER_URL"]
```

The public widget reads `site_config.biomixer_replacement_enabled` and `site_config.ontopanel_visualizer_url` before choosing the legacy or replacement iframe.

## Notes on SPARQL and LodView-style browsing

SPARQL is optional because not every OntoPortal deployment exposes the same triple-store endpoint. When an endpoint is configured, the visualizer sends standard SPARQL query requests and accepts SPARQL JSON results or simple RDF triple text. This makes it useful for curated “show me this exact class subset” diagrams without requiring a full editor workflow.

The resource panel is intentionally a lightweight LodView-style inspector rather than a full linked-data publishing server. It complements the graph by showing the selected IRI, labels, synonyms, definitions, visible relations, and SPARQL-described triples when available.


## Ontology Atlas mode

Atlas mode is the “giant map” view. It calls the OntoPortal class-list endpoint page by page, lays the loaded classes out into map-like regions, and gives users a draggable minimap viewport so they can move around the ontology like a large spatial canvas. The default Atlas budget is raised automatically so the map is useful immediately; **Load more map** expands by another batch and **Full atlas** loads as much of the ontology as the browser safety cap allows. For ontologies larger than the browser cap, the UI reports the remaining hidden count and should later be paired with a server-side aggregation endpoint.
