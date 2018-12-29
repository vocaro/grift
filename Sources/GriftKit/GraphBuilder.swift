import Foundation
import SourceKittenFramework
import SwiftGraph
import Graphviz

public typealias Vertex = String

public enum GraphBuilder {

    public static func build(files: [File]) -> UnweightedGraph<Vertex> {
        let graph = UnweightedGraph<Vertex>()

        return graph
    }

    public static func build(structures: [Structure], excluding regex: NSRegularExpression? = nil) -> UnweightedGraph<Vertex> {
        let graph = UnweightedGraph<Vertex>()
        for structure in structures {
            populate(graph: graph, from: structure.dictionary, excluding: regex)
        }
        return graph
    }

    public static func build(docs: [SwiftDocs]) -> UnweightedGraph<Vertex> {
        let graph = UnweightedGraph<Vertex>()
        for doc in docs {
            populate(graph: graph, from: doc.docsDictionary)
        }
        return graph
    }

    private static func populate(graph: UnweightedGraph<Vertex>, from dict: [String: SourceKitRepresentable], forVertexNamed name: String = "", excluding regex: NSRegularExpression? = nil) {

        var name = name

        if let typeName = dict[.typeName] as? String, !name.isEmpty {
            for singleTypeName in normalize(typeWithName: typeName) {
                guard !isExcluded(singleTypeName, regex: regex) else {
                    continue
                }
                graph.addVertextIfNotPresent(singleTypeName)
                graph.addEdgeIfNotPresent(from: name, to: singleTypeName, directed: true)
            }
        }

        if let newName = dict[.name] as? String, kindIsEnclosingType(kind: dict[.kind]) {
            name = newName
            graph.addVertextIfNotPresent(name)
        }

        if let substructures = dict[.substructure] as? [SourceKitRepresentable] {
            for case let substructureDict as [String: SourceKitRepresentable] in substructures {
                populate(graph: graph, from: substructureDict, forVertexNamed: name, excluding: regex)
            }
        }
    }

    private static func normalize(typeWithName name: String) -> [String] {
        return TypeNameExtractor.extractTypeNames(sourceKitTypeName: name)
    }    

    private static func isExcluded(_ name: String, regex: NSRegularExpression?) -> Bool {
        guard let regex = regex else {
            return false
        }
        
        let range = NSRange(name.startIndex..., in: name)
        let firstMatch = regex.rangeOfFirstMatch(in: name, range: range)
        return firstMatch.location != NSNotFound
    }
}
