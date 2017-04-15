//
//  main.swift
//  Task3
//
//  Created by Abdukodiri Kurbonzoda on 14/11/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

func removingDuplicates(from formulas: [Expression]) -> [Expression] {
    var addedFormulas = Set<String>()
    var duplicatesRemoved = [Expression]()
    for formula in formulas {
        let description = formula.description
        if !addedFormulas.contains(description) {
            addedFormulas.insert(description)
            duplicatesRemoved.append(formula)
        }
    }
    return duplicatesRemoved
}

do {
    let testsDirectory = "/Users/bigdreamer/Programming/logic2015/Others/Task3/Tests/"
    
    let inputTests = try FileManager().contentsOfDirectory(atPath: testsDirectory).filter { $0.hasSuffix(".in") }
    
    testCase: for var inputPath in inputTests {
        inputPath = testsDirectory + inputPath
        let expression = try String(contentsOfFile: inputPath)

        let typedExpression = expression.toExpression()
        let expressionVariables = typedExpression.distinctVariables()
        
        print("variables: \(expressionVariables.map { $0.description })")
        print("formula to prove: \(typedExpression.description)")
        
        var expressionProof = [[Expression]]()
        
        let masksCount = (1 << expressionVariables.count)
        
        
        print("masks:\r")
        
        for mask in 0..<masksCount {
            var considerations = [Expression: Bool]()
            for (index, variable) in expressionVariables.enumerated() {
                considerations[variable] = mask & (1 << (expressionVariables.count - index - 1)) != 0
            }
            
            print(considerations.map { $0.value ? $0.key.description : $0.key.description + "!" })
            
            if (!typedExpression.evaluate(considering: considerations)) {
                let answer = considerations.reduce("Высказывание ложно при ", { (result, consideration) in
                    return result + "\(consideration.key.description) = \(consideration.value ? "И" : "Л"), "
                })
                
                print(String(answer.characters.dropLast(2)))
                continue testCase
            }
            
            expressionProof.append(removingDuplicates(from: typedExpression.proof(considering: considerations)))
        }
        
        
        for alphaIndex in (0..<expressionVariables.count).reversed() {
            let alpha = expressionVariables[alphaIndex]
            
            print("alpha: \(alpha.description)")
            
            var currentStepProof = [[Expression]]()
            for mask in 0..<(1 << alphaIndex) {
                
                let gamma = expressionVariables.prefix(upTo: alphaIndex).enumerated().map {
                    mask & (1 << (alphaIndex - $0 - 1)) == 0 ? .negation($1) : $1
                }
                
                print("gamma: \(gamma.reduce("", { $0 + $1.description + ", " }))")
                
//                assert( expressionProof[mask * 2].last! == typedExpression)
                
                let notAlphaDeduction = proofDeduction(gamma: gamma,
                                                       alpha: .negation(alpha),
                                                       proof: (inference: typedExpression, proof: expressionProof[mask * 2]))
                
//                assert(expressionProof[mask * 2].contains(.negation(alpha)))
//                assert(notAlphaDeduction.last! == .implication(.negation(alpha), typedExpression))
//                
//                assert( expressionProof[mask * 2 + 1].last! == typedExpression)
                
                let alphaDeduction = proofDeduction(gamma: gamma,
                                                    alpha: alpha,
                                                    proof: (inference: typedExpression, proof: expressionProof[mask * 2 + 1]))
                
//                assert(expressionProof[mask * 2 + 1].contains(alpha))
                assert(alphaDeduction.last! == .implication(alpha, typedExpression))
                
                let alphaOrNotAlpha = aOrNotAProof.map { $0.toExpression().substituting(["A": alpha]) }
                
                let axiom8 = axioms[7].substituting(["A": alpha, "B": .negation(alpha), "C": typedExpression])
                
                guard case let .implication(_, mp1) = axiom8 else { fatalError() }
                
                guard case let .implication(_, mp2) = mp1 else { fatalError() }
                
                guard case let .implication(_, mp3) = mp2 else { fatalError() }
                
//                assert(mp3 == typedExpression)
                
                let alphaRemovingProof = notAlphaDeduction + alphaDeduction + alphaOrNotAlpha + [axiom8, mp1, mp2, mp3]
                
                currentStepProof.append(removingDuplicates(from: alphaRemovingProof))
            }
            
            expressionProof = currentStepProof
            
//            assert(expressionProof.count == (1 << alphaIndex))
        }
        
        let outputPath = inputPath.replacingOccurrences(of: ".in", with: ".out")
        try expressionProof[0].reduce("", { $0 + $1.description + "\r" })
            .write(toFile: outputPath, atomically: true, encoding: .utf8)
    }
} catch {
        print("an error occured, cause: \(error)")
}
