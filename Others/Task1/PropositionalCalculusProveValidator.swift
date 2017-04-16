//
//  Prover.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 15.04.17.
//  Copyright © 2017 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

typealias FormulaInferenceType = (line: Int, formula: Expression, type: InferenceType)

func modusPonensInference(of formula: Expression, from formulas: [Expression]) -> (Int, Int)? {
    for deltaJ in formulas.enumerated() {
        switch deltaJ.element {
        case let .implication(lhs, rhs) where rhs == formula:
            if let first = formulas.enumerated().first(where: { $0.element == lhs }) {
                return (first.offset, deltaJ.offset)
            }
        default:
            break
        }
    }
    return nil
}

func validatePropositionalCalculusProve(inferenceFile: InferenceFile) -> [FormulaInferenceType] {
    let gamma = inferenceFile.header.gamma
    let inference = inferenceFile.header.inference
    let proof = inferenceFile.proof
    
    assert(inference == proof.last!)
    
    var formulasInferenceTypes = [FormulaInferenceType]()
    
    for (index, formula) in proof.enumerated() {
        let inferenceType: InferenceType
        if let axiomNumber = axiomNumber(of: formula) {
            inferenceType = .axiom(axiomNumber)
        } else if let assumptionNumber = gamma.enumerated().first(where: { $0.element == formula })?.offset {
            inferenceType = .assumption(assumptionNumber)
        } else if let mp = modusPonensInference(of: formula, from: Array(proof.prefix(upTo: index))) {
            inferenceType = .modusPonens(mp.0, mp.1)
        } else {
            inferenceType = .notProven
        }
        formulasInferenceTypes.append((line: index, formula: formula, type: inferenceType))
    }
    return formulasInferenceTypes
}
