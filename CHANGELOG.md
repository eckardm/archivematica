dev (1.4.0)
===========

* Remove unused Elasticsearch backup code (#8076)
* Improve performance of indexing AIP by saving uncompressed METS (#7424)
* Index MODS identifiers in Elasticsearch (#7424)
* Track file events in transfer METS using amdSecs (#7714)
* Add a new "processed structMap" which captures the transfer's final state (#7714)
* Use the Storage Service, not Elasticsearch, to look up file metadata in SIP arrange (#7714)
* Improve Dublin Core namespacing for metadata generated from metadata.csv and from template (#8007)
* Display additional metadata (number of files, size) from the storage service (#7853)
* Accession IDs associate with Transfers again (#7442)
* Remove Elasticsearch tool that is now maintained in archivematica-devtools
* Log exceptions in start_transfer (#8117)
* Archivist's Toolkit upload: use SQL placeholders instead of string interpolation (#7771)
* Fail SIP if checksum verification fails (#8825)
* Move logs to /var/archivematica/sharedDirectory; separate dashboard logs into its own file (#6647)
* Handle linking_agent as an integer, not a foreign key, in Django models (#8230)
* Index MODS identifiers in the aips/aipfile index (#8266)
* Fix bag transfer names (#8229)
* DSpace transfer type accepts either files or folders