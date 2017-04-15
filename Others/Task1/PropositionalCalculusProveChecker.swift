//
//  Prover.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 15.04.17.
//  Copyright © 2017 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

typealias FormulaInferenceType = (line: Int, formula: Expression, type: InferenceType)

func checkPropositionalCalculusProve(inferenceFile: InferenceFile) -> [FormulaInferenceType] {
    let gamma = inferenceFile.header.gamma
    let inference = inferenceFile.header.inference
    let proof = inferenceFile.proof.proof
    
    assert(inference == proof.last!)
    
    var formulasInferenceTypes = [FormulaInferenceType]()
//    
//    for expression in proof.enumerated() {
//        let inference: FormulaInferenceType
//        if let axiomNumber = axiomNumber(of: expression.element) {
//            inference = (expression.offset, expression.element, .axiom(axiomNumber + 1))
//        } else if let assumptionNumber = gamma.enumerated().first(where: { $0.element == expression.element })?.offset {
//            inference = (expression.offset, expression.element, .assumption(assumptionNumber + 1))
//        } else {
//            let prefix = proof.prefix(upTo: expression.offset)
//            let mp: (Int, Int)?
//            
//            iteration: for deltaJ in prefix.enumerated() {
//                switch deltaJ {
//                case let .implication(lhs, rhs) where rhs == expression.element:
//                    if let first = prefix.prefix(upTo: deltaJ.offset).enumerated().first(where: { $0.element =  })
//                default:
//                    break
//                }
//            }
//        }
//        
//        formulasInferenceTypes.append(inference)
//    }
}
