//
//  main.swift
//  Task3
//
//  Created by Abdukodiri Kurbonzoda on 14/11/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

private let testsDirectory = "/Users/bigdreamer/Programming/logic2015/Others/Task3/Tests/"

do {
    let inputTests = try FileManager().contentsOfDirectory(atPath: testsDirectory).filter { $0.hasSuffix(".in") }
    
    testCase: for var inputPath in inputTests {
        inputPath = testsDirectory + inputPath
        let expression = try String(contentsOfFile: inputPath)

        let typedExpression = expression.toExpression()
        let expressionVariables = typedExpression.distinctVariables()
        
        print("variables: \(expressionVariables.map { $0.description })")
        print("formula to prove: \(typedExpression.description)")
        
        var expressionProof = [[FormulaInferenceType]]()
        
        let masksCount = (1 << expressionVariables.count)
        
        
        print("masks:\r")
        
        for mask in 0..<masksCount {
            var considerations = [Expression: Bool]()
            var gamma = [Expression]()
            for (index, variable) in expressionVariables.enumerated() {
                considerations[variable] = mask & (1 << (expressionVariables.count - index - 1)) != 0
                gamma.append(mask & (1 << (expressionVariables.count - index - 1)) == 0 ? .negation(variable) : variable)
            }
            
            print(considerations.map { $0.value ? $0.key.description : $0.key.description + "!" })
            
            if (!typedExpression.evaluate(considering: considerations)) {
                let answer = considerations.reduce("Высказывание ложно при ", { (result, consideration) in
                    return result + "\(consideration.key.description) = \(consideration.value ? "И" : "Л"), "
                })
                
                print(String(answer.characters.dropLast(2)))
                continue testCase
            }
            
            expressionProof.append(typedExpression.proof(considering: considerations, gamma: gamma))
        }
        
        
        for alphaIndex in (0..<expressionVariables.count).reversed() {
            let alpha = expressionVariables[alphaIndex]
            
            print("alpha: \(alpha.description)")
            
            var currentStepProof = [[FormulaInferenceType]]()
            for mask in 0..<(1 << alphaIndex) {
                
                let gamma = expressionVariables.prefix(upTo: alphaIndex).enumerated().map {
                    mask & (1 << (alphaIndex - $0 - 1)) == 0 ? .negation($1) : $1
                }
                
                print("gamma: \(gamma.reduce("", { $0 + $1.description + ", " }))")
                
//                assert( expressionProof[mask * 2].last!.formula == typedExpression)
                let notAlphaDeduction = proofDeduction(header: (gamma: gamma + [.negation(alpha)], inference: typedExpression),
                                                       proof: expressionProof[mask * 2])
                var alphaRemovingProof = notAlphaDeduction
//                assert(expressionProof[mask * 2].contains { $0.formula == .negation(alpha) } )
//                assert(notAlphaDeduction.last!.formula == .implication(.negation(alpha), typedExpression))

//                assert( expressionProof[mask * 2 + 1].last!.formula == typedExpression)
                let alphaDeduction = proofDeduction(header: (gamma: gamma + [alpha], inference: typedExpression),
                                                    proof: expressionProof[mask * 2 + 1])
                alphaRemovingProof.append(contentsOf: alphaDeduction.formulaIndicesShifted(by: alphaRemovingProof.count))
//                assert(expressionProof[mask * 2 + 1].contains { $0.formula == alpha })
//                assert(alphaDeduction.last!.formula == .implication(alpha, typedExpression))
                
                let alphaOrNotAlpha: [FormulaInferenceType]
                    = aOrNotAProof.map { ($0.line, $0.formula.substituting(["A": alpha]), $0.type) }
                alphaRemovingProof.append(contentsOf: alphaOrNotAlpha.formulaIndicesShifted(by: alphaRemovingProof.count))
                
                let axiom8 = axioms[7].substituting(["A": alpha, "B": .negation(alpha), "C": typedExpression])
                alphaRemovingProof.append( (alphaRemovingProof.count, axiom8, InferenceType.axiom(7)) )
                
                guard case let .implication(_, mp1) = axiom8 else { fatalError() }
                alphaRemovingProof.append( (alphaRemovingProof.count, mp1, InferenceType.modusPonens(notAlphaDeduction.count + alphaDeduction.count - 1, alphaRemovingProof.count - 1)) )
                
                guard case let .implication(_, mp2) = mp1 else { fatalError() }
                alphaRemovingProof.append( (alphaRemovingProof.count, mp2, InferenceType.modusPonens(notAlphaDeduction.count - 1, alphaRemovingProof.count - 1)) )
                
                guard case let .implication(_, mp3) = mp2 else { fatalError() }
                alphaRemovingProof.append( (alphaRemovingProof.count, mp3, InferenceType.modusPonens(notAlphaDeduction.count + alphaDeduction.count + alphaOrNotAlpha.count - 1, alphaRemovingProof.count - 1)) )
                
//                assert(mp3 == typedExpression)
                
                currentStepProof.append(alphaRemovingProof)
            }
            
            expressionProof = currentStepProof
//            assert(expressionProof.count == (1 << alphaIndex))
        }
        
        let outputPath = inputPath.replacingOccurrences(of: ".in", with: ".out")
        try expressionProof[0].reduce("", { $0 + $1.formula.description + "\r" })
            .write(toFile: outputPath, atomically: false, encoding: .utf8)
    }
} catch {
        print("an error occured, cause: \(error)")
}
