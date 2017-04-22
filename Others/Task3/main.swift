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
        let inputFormula = try String(contentsOfFile: testsDirectory + inputPath).toFormula()
        let inputFormulaVariables = inputFormula.distinctVariables()
        
//        print("variables: \(inputFormulaVariables.map { $0.description })")
//        print("formula to prove: \(inputFormula.description)")
        
        var inputFormulaProof = [[FormulaInferenceType]]()
        
        let masksCount = (1 << inputFormulaVariables.count)
        
        
//        print("masks:\r")
        
        for mask in 0..<masksCount {
            var considerations = [Formula: Bool]()
            for (index, variable) in inputFormulaVariables.enumerated() {
                considerations[variable] = mask & (1 << (inputFormulaVariables.count - index - 1)) != 0
            }
            
            let gamma = considerations.map { (variable, value) -> Formula in
                return value ? variable : Formula(.negation(variable))
            }
            
//            print(considerations.map { $0.value ? $0.key.description : $0.key.description + "!" })
            
            if (!inputFormula.evaluate(considering: considerations)) {
                let answer = considerations.reduce("Высказывание ложно при ", { (result, consideration) in
                    return result + "\(consideration.key.description) = \(consideration.value ? "И" : "Л"), "
                })
                
                print(String(answer.characters.dropLast(2)))
                continue testCase
            }
            
            inputFormulaProof.append(inputFormula.proof(considering: considerations, gamma: gamma))
        }
        
        
        for alphaIndex in (0..<inputFormulaVariables.count).reversed() {
            let alpha = inputFormulaVariables[alphaIndex]
            
//            print("alpha: \(alpha.description)")
            
            var currentStepProof = [[FormulaInferenceType]]()
            for mask in 0..<(1 << alphaIndex) {
                
                let gamma = inputFormulaVariables.prefix(upTo: alphaIndex).enumerated().map {
                    mask & (1 << (alphaIndex - $0 - 1)) == 0 ? Formula(.negation($1)) : $1
                }
                
//                print("gamma: \(gamma.reduce("", { $0 + $1.description + ", " }))")
                
//                assert( inputFormulaProof[mask * 2].last!.formula == inputFormula)
                let notAlphaDeduction = proofDeduction(header: (gamma: gamma + [Formula(.negation(alpha))],
                                                                inference: inputFormula),
                                                       proof: inputFormulaProof[mask * 2])
                var alphaRemovingProof = notAlphaDeduction
//                assert(inputFormulaProof[mask * 2].contains { $0.formula == Formula(.negation(alpha)) })
//                assert(notAlphaDeduction.last!.formula == Formula(.implication(Formula(.negation(alpha)), inputFormula)))
//
//                assert(inputFormulaProof[mask * 2 + 1].last!.formula == inputFormula)
                let alphaDeduction = proofDeduction(header: (gamma: gamma + [alpha], inference: inputFormula),
                                                    proof: inputFormulaProof[mask * 2 + 1])
                alphaRemovingProof.append(contentsOf: alphaDeduction.formulaIndicesShifted(by: alphaRemovingProof.count))
//                assert(inputFormulaProof[mask * 2 + 1].contains { $0.formula == alpha })
//                assert(alphaDeduction.last!.formula == Formula(.implication(alpha, inputFormula)))
                
                let alphaOrNotAlpha: [FormulaInferenceType]
                    = aOrNotAProof.map { ($0.line, $0.formula.substituting(["A": alpha]), $0.type) }
                alphaRemovingProof.append(contentsOf: alphaOrNotAlpha.formulaIndicesShifted(by: alphaRemovingProof.count))
                
                let axiom8 = axioms[7].substituting(["A": alpha, "B": Formula(.negation(alpha)), "C": inputFormula])
                alphaRemovingProof.append( (alphaRemovingProof.count, axiom8, InferenceType.axiom(7)) )
                
                guard case let .implication(_, mp1) = axiom8.unboxed else { fatalError() }
                alphaRemovingProof.append( (alphaRemovingProof.count, mp1, InferenceType.modusPonens(notAlphaDeduction.count + alphaDeduction.count - 1, alphaRemovingProof.count - 1)) )
                
                guard case let .implication(_, mp2) = mp1.unboxed else { fatalError() }
                alphaRemovingProof.append( (alphaRemovingProof.count, mp2, InferenceType.modusPonens(notAlphaDeduction.count - 1, alphaRemovingProof.count - 1)) )
                
                guard case let .implication(_, mp3) = mp2.unboxed else { fatalError() }
                alphaRemovingProof.append( (alphaRemovingProof.count, mp3, InferenceType.modusPonens(notAlphaDeduction.count + alphaDeduction.count + alphaOrNotAlpha.count - 1, alphaRemovingProof.count - 1)) )
                
//                assert(mp3 == inputFormula)
                
                currentStepProof.append(alphaRemovingProof)
            }
            
            inputFormulaProof = currentStepProof
//            assert(inputFormulaProof.count == (1 << alphaIndex))
        }
        
        let outputPath = testsDirectory + inputPath.replacingOccurrences(of: ".in", with: ".out")
        try inputFormulaProof[0].reduce("", { $0 + $1.formula.description + "\r" })
            .write(toFile: outputPath, atomically: false, encoding: .utf8)
    }
} catch {
        print("an error occured, cause: \(error)")
}
