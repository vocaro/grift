//
//  DependenciesCommand.swift
//  Grift
//
//  Created by Kevin Lundberg on 3/23/17.
//  Copyright © 2017 Kevin Lundberg. All rights reserved.
//

import Commandant
import GriftKit
import Result
import SourceKittenFramework
import SwiftGraph
import Foundation

struct GriftError: Error, CustomStringConvertible {
    var message: String

    var description: String {
        return message
    }
}

struct DependenciesCommand: CommandProtocol {

    let verb: String = "dependencies"
    let function: String = "Generates a dependency graph from swift files in the given directory"

    func run(_ options: DependenciesOptions) -> Result<(), GriftError> {
        do {
            let structures = try GriftKit.structures(at: options.path)
            let graph = GraphBuilder.build(structures: structures, excluding: try options.allExcludes())
            let dot = graph.graphviz()
            print(dot.description)

            return .success(())
        } catch {
            return .failure(GriftError(message: "\(error)"))
        }
    }
}

struct DependenciesOptions: OptionsProtocol {
    let path: String
    let defaultExcludes: Bool
    let excludes: String

    func allExcludes() throws -> NSRegularExpression? {
        var allExcludes = [String]()
        
        if defaultExcludes {
            allExcludes.append("^UI.*")
            allExcludes.append("^CG.*")
            allExcludes.append("^NS.*")
            allExcludes.append("^String$")
            allExcludes.append("^Array$")
            allExcludes.append("^Dictionary$")
            allExcludes.append("^Bool$")
            allExcludes.append("^Int$")
            allExcludes.append("^UInt$")
            allExcludes.append("^Float$")
            allExcludes.append("^Double$")
            allExcludes.append("^Self$")
            allExcludes.append("^Any$")
            allExcludes.append("^AnyObject$")
            allExcludes.append("^AnyClass$")
            allExcludes.append("^Date$")
            allExcludes.append("^URL$")
        }

        allExcludes += excludes.split(separator: ",").map { String($0) }

        if allExcludes.isEmpty {
            return nil
        }

        return try NSRegularExpression(pattern: allExcludes.joined(separator: "|"))
    }

    static func create(_ path: String) -> (Bool) -> (String) -> DependenciesOptions {
        return { defaultExcludes in { excludes in DependenciesOptions(path: path, defaultExcludes: defaultExcludes, excludes: excludes) } }
    }

    static func evaluate(_ m: CommandMode) -> Result<DependenciesOptions, CommandantError<GriftError>> {
        return create
            <*> m <| Option(key: "path", defaultValue: ".", usage: "The path to generate a dependency graph from")
            <*> m <| Option(key: "defaultExcludes", defaultValue: false, usage: "If true, adds a set of default symbols to the excludes list (UI*, CG*, etc.)")
            <*> m <| Option(key: "excludes", defaultValue: "", usage: "List of comma-separated symbols to exclude from the graph")
    }
}
