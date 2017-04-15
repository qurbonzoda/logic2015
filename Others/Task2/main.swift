//
//  main.swift
//  Task2
//
//  Created by Abdukodiri Kurbonzoda on 06/08/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

do {
    let testsDirectory = "/Users/bigdreamer/Programming/logic2015/Others/Task2/Tests/"
    
    let inputTests = try FileManager().contentsOfDirectory(atPath: testsDirectory).filter { $0.hasSuffix(".in") }

    for var inputPath in inputTests {
        inputPath = testsDirectory + inputPath
        let outputPath = inputPath.replacingOccurrences(of: ".in", with: ".out")

        let file = try parse(fileAtPath: inputPath)
        let assumptions = file.header.gamma
        
        try proofDeduction(gamma: Array(assumptions.dropLast()), alpha: assumptions.last!, proof: file.proof)
            .reduce("", { $0 + $1.description + "\n" })
            .write(toFile: outputPath, atomically: true, encoding: .utf8)
    
}
} catch {
    print("an error occured, cause: \(error)")
}
