//
//  Deduction.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 16/11/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

func proofDeduction(header: Header, proof: [FormulaInferenceType]) -> [FormulaInferenceType] {
    assert(header.gamma.count > 0)
    assert(proof.count > 0)
    assert(header.inference == proof.last!.formula)
    
    let alpha = header.gamma.last!
    
    var deductionProof = [FormulaInferenceType]()
    var formulaNewIndex = [Int]()
    
//    let badFormula = "(b->c)"
    
    for inference in proof {
        let precedingFormulas: [FormulaInferenceType]
        
        if inference.formula == alpha {
            precedingFormulas = [
                (0, "A->(A->A)",                                .axiom(0)),
                (1, "(A->(A->A))->(A->((A->A)->A))->(A->A)",    .axiom(1)),
                (2, "(A->((A->A)->A))->(A->A)",                 .modusPonens(0, 1)),
                (3, "(A->((A->A)->A))",                         .axiom(0)),
                (4, "A->A",                                     .modusPonens(3, 2))
            ]
            .map { ($0.0, $0.1.toFormula().substituting(["A": alpha]), $0.2) }
        } else {
            switch inference.type {
            case .axiom(let i):
                precedingFormulas = [
                    (0, "A",            .axiom(i)),
                    (1, "A->(B->A)",    .axiom(0)),
                    (2, "B->A",         .modusPonens(0, 1))
                ]
                .map { ($0.0, $0.1.toFormula().substituting(["A": inference.formula, "B": alpha]), $0.2) }
                    
            case .assumption(let i):
//                assert(header.gamma[i] == inference.formula)
                precedingFormulas = [
                    (0, "A",            .assumption(i)),
                    (1, "A->(B->A)",    .axiom(0)),
                    (2, "B->A",         .modusPonens(0, 1))
                ]
                .map { ($0.0, $0.1.toFormula().substituting(["A": inference.formula, "B": alpha]), $0.2) }
                
            case .modusPonens(let j, let k):
                precedingFormulas = [
                    (0, "(A->B)->(A->(B->C))->(A->C)",  .axiom(1)),
                    (1, "(A->(B->C))->(A->C)",          .modusPonens(formulaNewIndex[j] - deductionProof.count, 0)),
                    (2, "A->C",                         .modusPonens(formulaNewIndex[k] - deductionProof.count, 1))
                ]
                .map { ($0.0, $0.1.toFormula().substituting(["A": alpha, "B": proof[j].formula, "C": inference.formula]), $0.2) }
                
            case .notProven:
                fatalError("The proof must be correct to do deduction")
            }
        }
        
//        if (precedingFormulas.contains(where: { $0.formula.description == badFormula })) {
//            print(precedingFormulas.reduce("") { $0 + "\r" + $1.formula.description })
//        }
        
        deductionProof.append(contentsOf: precedingFormulas.formulaIndicesShifted(by: deductionProof.count))
        formulaNewIndex.append(deductionProof.count - 1)
    }
    
//    validate(gamma: Array(header.gamma.dropLast()), inference: Formula(.implication(alpha, header.inference)), inferenceProof: deductionProof)
    
    return deductionProof
}

private func validate(gamma: [Formula], inference: Formula, inferenceProof: [FormulaInferenceType]) {
    let inferenceFile = (header: (gamma: gamma, inference: inference),
                                   proof: inferenceProof.map { $0.formula })
    let validation = validatePropositionalCalculusProve(inferenceFile: inferenceFile)
    
    print("################\r\r" + validation
        .map { "(\($0.line + 1)) \($0.formula.description) (\($0.type.description))" }
        .reduce("") { $0 + $1 + "\r" })
    
    assert(!validation.contains {
        switch $0.type {
        case .notProven:    return true
        default:            return false
        }
    })
}
