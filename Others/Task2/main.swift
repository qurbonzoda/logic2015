//
//  main.swift
//  Task2
//
//  Created by Abdukodiri Kurbonzoda on 06/08/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

private let testsDirectory = "/Users/bigdreamer/Programming/logic2015/Others/Task2/Tests/"

do {
    let inputTests = try FileManager().contentsOfDirectory(atPath: testsDirectory).filter { $0.hasSuffix(".in") }

    for var inputPath in inputTests {
        inputPath = testsDirectory + inputPath
        let outputPath = inputPath.replacingOccurrences(of: ".in", with: ".out")

        let inferenceFile = try parse(fileAtPath: inputPath)
        let inferenceTypes = validatePropositionalCalculusProve(inferenceFile: inferenceFile)
        
        try proofDeduction(header: inferenceFile.header, proof: inferenceTypes)
            .reduce("", { $0 + $1.formula.description + "\n" })
            .write(toFile: outputPath, atomically: false, encoding: .utf8)
    
}
} catch {
    print("an error occured, cause: \(error)")
}
