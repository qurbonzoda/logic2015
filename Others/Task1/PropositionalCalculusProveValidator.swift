//
//  Prover.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 15.04.17.
//  Copyright © 2017 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

typealias FormulaInferenceType = (line: Int, formula: Expression, type: InferenceType)

func validatePropositionalCalculusProve(inferenceFile: InferenceFile) -> [FormulaInferenceType] {
    let inference = inferenceFile.header.inference
    let proof = inferenceFile.proof
    
    var assumptionIndex = [Expression : Int]()
    inferenceFile.header.gamma.enumerated().forEach { assumptionIndex[$1] = $0 }
    
    var formulaIndex = Dictionary<Expression, Int>(minimumCapacity: proof.count * 5)
    var deducingsOfInference = Dictionary<Expression, [(index: Int, deducing: Expression)]>(minimumCapacity: proof.count * 5)
    let maxDeducingsCount = 20
    
    func modusPonensInference(of formula: Expression, from precedingFormulas: ArraySlice<Expression>) -> (Int, Int)? {
        guard let deducingsOfFormula = deducingsOfInference[formula] else {
            return nil
        }
        
        for deltaJ in deducingsOfFormula {
            if let deducingFormulaIndex = formulaIndex[deltaJ.deducing] {
                return (deducingFormulaIndex, deltaJ.index)
            }
        }
        
        if deducingsOfFormula.count < maxDeducingsCount {
            return nil
        }
        
        for precedingFormula in precedingFormulas.enumerated() {
            switch precedingFormula.element {
            case let .implication(lhs, rhs) where rhs == formula:
                if let lhsIndex = formulaIndex[lhs] {
                    return (lhsIndex, precedingFormula.offset)
                }
            default:
                break
            }
        }
        return nil
    }
    
    assert(inference == proof.last!)
    
    var formulasInferenceTypes = [FormulaInferenceType]()
    
    for (index, formula) in proof.enumerated() {
        let inferenceType: InferenceType
        if let axiomNumber = axiomNumber(of: formula) {
            inferenceType = .axiom(axiomNumber)
        } else if let assumptionNumber = assumptionIndex[formula] {
            inferenceType = .assumption(assumptionNumber)
        } else if let mp = modusPonensInference(of: formula, from: proof.prefix(upTo: index)) {
            inferenceType = .modusPonens(mp.0, mp.1)
        } else {
            inferenceType = .notProven
        }
        formulasInferenceTypes.append((line: index, formula: formula, type: inferenceType))
        formulaIndex[formula] = index
        
        switch formula {
        case let .implication(lhs, rhs):
            if deducingsOfInference[rhs] == nil {
                deducingsOfInference[rhs] = []
            }
            if deducingsOfInference[rhs]!.count < maxDeducingsCount {
                deducingsOfInference[rhs]!.append((index, lhs))
            }
        default:
            break
        }
    }
    return formulasInferenceTypes
}
