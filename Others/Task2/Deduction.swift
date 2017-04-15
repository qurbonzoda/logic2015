//
//  Deduction.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 16/11/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

func proofDeduction(gamma: [Expression], alpha: Expression, proof: InferenceProof) -> [Expression] {
    //assert(proof.inference == proof.proof.last!)
    var deductionProof = [Expression]()
    
    for (index, formula) in proof.proof.enumerated() {
        let precedingFormulas: [Expression]
        
        if isAxiom(formula) || gamma.contains(formula) {
            precedingFormulas = [
                "A",
                "A->(B->A)"
                ].map { $0.toExpression().substituting(["A": formula, "B": alpha]) }
        } else if formula == alpha {
            precedingFormulas = [
                "A->(A->A)",
                "(A->(A->A))->(A->((A->A)->A))->(A->A)",
                "(A->((A->A)->A))->(A->A)",
                "(A->((A->A)->A))"
                ].map { $0.toExpression().substituting(["A": formula]) }
        } else {
            let prefix = proof.proof.prefix(upTo: index)
            
            var first: Expression?
            iteration: for precedingFormula in prefix {
                switch precedingFormula {
                case let .implication(lhs, rhs) where rhs == formula:
                    if prefix.contains(lhs) {
                        first = lhs
                        break iteration
                    }
                    break
                default:
                    break
                }
            }
            
//            if first == nil {
//                print("for (\(index), \(formula.description)) nothing was found.")
//                print("assumptions: \(gamma.reduce("", { $0 + $1.description + " " }))")
//                print("preceding formulas: \(prefix.reduce("", { $0 + "\r" + $1.description }))")
//                print("following formulas: \(proof.proof.suffix(from: index).reduce("", { $0 + "\r" + $1.description }))")
//            }
            
            precedingFormulas = [
                "(A->B)->(A->(B->C))->(A->C)",
                "(A->(B->C))->(A->C)"
                ].map { $0.toExpression().substituting(["A": alpha, "B": first!, "C": formula]) }
        }
        
        deductionProof.append(contentsOf: precedingFormulas)
        deductionProof.append(.implication(alpha, formula))
    }
    return deductionProof
}
