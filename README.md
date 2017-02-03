# SPARQLclient
Simple SPARQL endpoints access library in swift

    dependencies: [
       .Package(url: "https://github.com/potan/SPARQLclient.git", majorVersion: 0),
    ]

import SPARQLclient

let client = try! SPARQLclient(url: keggEP)

let (vars, data) = try! client.select(
     query: "SELECT distinct ?o ?p ?v WHERE {?o &lt;http://purl.org/dc/terms/title&gt; "Calcium signaling pathway"@en ; ?p ?v}" )
