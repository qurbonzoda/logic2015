//
//  main.swift
//  Task1
//
//  Created by Abdukodiri Kurbonzoda on 15.04.17.
//  Copyright © 2017 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

private let testsDirectory = "/Users/bigdreamer/Programming/logic2015/Others/Task1/Tests/"

do {
    let inputTests = try FileManager().contentsOfDirectory(atPath: testsDirectory).filter { $0.hasSuffix(".in") }
    
    for var inputPath in inputTests {
        inputPath = testsDirectory + inputPath
        let outputPath = inputPath.replacingOccurrences(of: ".in", with: ".out")
        
        let inferenceFile = try parse(fileAtPath: inputPath)
        let inferenceTypes = validatePropositionalCalculusProve(inferenceFile: inferenceFile)
        
        let header = inferenceFile.header
        let gammaRepresentation: String
        if let first = header.gamma.first {
            gammaRepresentation = header.gamma.dropFirst().reduce(first.description) { $0 + "," + $1.description }
        } else {
            gammaRepresentation = ""
        }
        
        try (gammaRepresentation + "|-" + header.inference.description + "\r"
            + inferenceTypes
                .map { "(\($0.line + 1)) \($0.formula.description) (\($0.type.description))" }
                .reduce("") { $0 + $1 + "\r" })
            .write(toFile: outputPath, atomically: false, encoding: .utf8)
    }
} catch {
    print("an error occured, cause: \(error)")
}
