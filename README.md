# SPARQLclient
Simple SPARQL endpoints access library in swift

    dependencies: [
       .Package(url: "https://github.com/potan/SPARQLclient.git", majorVersion: 0),
    ]

import SPARQLclient

let client = try! SPARQLclient(url: keggEP)

let (vars, data) = try! client.select(query:"select ?x, ?y where { ?x a ?y } limit 17")
