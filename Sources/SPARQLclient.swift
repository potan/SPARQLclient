
import HTTPClient
import Foundation
//import Regex
//import Core
//import HTTP

public let dbpediaEP = "http://dbpedia.org/sparql"
public let keggEP = "http://kegg.bio2rdf.org/sparql"
public let goEP = "http://go.bio2rdf.org/sparql"
public let pubmedEP = "http://pubmed.bio2rdf.org/sparql"
public let pdbEP = "http://pdb.bio2rdf.org/sparql"

public enum RDFnode<Row> {
  case uri(String)
  case lit(String)
  case slit(String, String)
  case tlit(String, String)
  case unknown(Row)
}

extension Dictionary {
    func merge(_ otherDictionary: [Key: Value]) -> [Key: Value] {
        var mergedDict: [Key: Value] = [:]
        [self, otherDictionary].forEach { dict in
            for (key, value) in dict {
                mergedDict[key] = value
            }
        }
        return mergedDict
    }
    func mapValue<V>(_ f: (Value) -> V) -> [Key: V] {
        var newDict: [Key: V] = [:]
        for (key, value) in self {
            newDict[key] = f(value)
        }
        return newDict
    }
}

func map2node(val: Map) -> RDFnode<Map> {
    guard case .string(let v) = val["value"] else {
      return .unknown(val)
    }
    switch val["type"] {
      case .string("uri"):
        return .uri(v)
      case .string("literal"):
        switch val["xml:lang"] {
          case .string(let lang):
           return .slit(v, lang)
          default:
           return .lit(v)
        }
      case .string("typed-literal"):
        return .tlit(v, try! val["datatype"].asString())
      default:
        return .unknown(val)
    }
  }

public protocol SPARQLprotocol {
    func select(query: String) throws -> ([String]?, [[String: RDFnode<Map>]]?)
    func select(query: String, graph: String?) throws -> ([String]?, [[String: RDFnode<Map>]]?)
}

public struct SPARQLclient : SPARQLprotocol {

    let client: Client
    let path: String

    public init(url: String) throws {
     guard let u = URL(string: url) else {
       throw URLError.invalidURL
     }
     path = u.relativePath
     client = try Client(url: url)
    }

    let contentNegotiation = ContentNegotiationMiddleware(mediaTypes: [.json /*, .urlEncodedForm*/], mode: .client)

    public func select(query: String, graph: String?) throws -> ([String]?, [[String: RDFnode<Map>]]?) {
       let g: String
       if let gr = graph {
         g = "default-graph-uri=" + gr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "&"
       } else {
         g = ""
       }
       let response = try! client.get(path+"?" + g + "query="+query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
                               headers: ["Accept" : "application/sparql-results+json"],
                               middleware: [contentNegotiation]
                              )
//       print(response)
       let c = response.content
       let vars = try c?["head"]["vars"].asArray().map({try $0.asString()})
       let data = try c?["results"]["bindings"].asArray().map({try $0.asDictionary().mapValue(map2node)})
       return (vars, data) 
    }
    public func select(query: String) throws -> ([String]?, [[String: RDFnode<Map>]]?) {
      return try select(query: query, graph: nil)
    }
}
