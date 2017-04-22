//
//  Extensions.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 14/11/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation


extension Formula {
    func evaluate(considering dict: [Formula: Bool]) -> Bool {
        switch self.unboxed {
        case .variable(_):
            return dict[self]!
        case let .implication(lhs, rhs):
            let p = lhs.evaluate(considering: dict)
            let q = rhs.evaluate(considering: dict)
            return !p || q
        case let .disjunction(lhs, rhs):
            let p = lhs.evaluate(considering: dict)
            let q = rhs.evaluate(considering: dict)
            return p || q
        case let .conjunction(lhs, rhs):
            let p = lhs.evaluate(considering: dict)
            let q = rhs.evaluate(considering: dict)
            return p && q
        case .negation(let negated):
            return !negated.evaluate(considering: dict)
        }
    }
    
    func distinctVariables() -> [Formula] {
        var variables = Set<Formula>()
        
        self.postOrderTraversal {
            switch $0.unboxed {
            case .variable(_):
                variables.insert($0)
            default:
                break
            }
        }
        
        return Array(variables)
    }
    
    private func postOrderTraversal(_ body: (Formula) -> Void) {
        switch self.unboxed {
        case .variable(_):
            break
        case .implication(let lhs, let rhs),
             .disjunction(let lhs, let rhs),
             .conjunction(let lhs, let rhs):
            lhs.postOrderTraversal(body)
            rhs.postOrderTraversal(body)
        case .negation(let negated):
            negated.postOrderTraversal(body)
        }
        
        body(self)
    }
    
    func proof(considering dict: [Formula: Bool], gamma: [Formula]) -> [FormulaInferenceType] {
        var formulas = [FormulaInferenceType]()
        
        self.postOrderTraversal {
            let proof: [FormulaInferenceType]
            
            switch $0.unboxed {
            case .variable(_):
                let variable = $0
                proof = variableProof[variable.evaluate(considering: dict)]!.map {
                    ($0.line, $0.formula.substituting(["A": variable]), $0.type)
                }
            case let .implication(lhs, rhs):
                proof = implicationProof[BoolPair(A: lhs.evaluate(considering: dict), B: rhs.evaluate(considering: dict))]!.map {
                    ($0.line, $0.formula.substituting(["A": lhs, "B": rhs]), $0.type)
                }
            case let .disjunction(lhs, rhs):
                proof = disjunctionProof[BoolPair(A: lhs.evaluate(considering: dict), B: rhs.evaluate(considering: dict))]!.map {
                    ($0.line, $0.formula.substituting(["A": lhs, "B": rhs]), $0.type)
                }
            case let .conjunction(lhs, rhs):
                proof = conjunctionProof[BoolPair(A: lhs.evaluate(considering: dict), B: rhs.evaluate(considering: dict))]!.map {
                    ($0.line, $0.formula.substituting(["A": lhs, "B": rhs]), $0.type)
                }
            case .negation(let negated):
                proof = negationProof[negated.evaluate(considering: dict)]!.map {
                    ($0.line, $0.formula.substituting(["A": negated]), $0.type)
                }
            }
            
            let assumptionsCorrected: [FormulaInferenceType] = proof.map { inference in
                let actualType: InferenceType
                
                switch inference.type {
                case .assumption(_):
                    if let indexInGamma = gamma.index(of: inference.formula) {
                        actualType = .assumption(indexInGamma)
                    } else if let indexInFormulas = formulas.index(where: { inference.formula == $0.formula }) {
                        switch formulas[indexInFormulas].type {
                        case .modusPonens(let i, let j):
                            actualType = .modusPonens(i - formulas.count, j - formulas.count)
                        default:
                            actualType = formulas[indexInFormulas].type
                        }
                    } else {
                        fatalError("Unreachable")
                    }
                default:
                    actualType = inference.type
                }
                
                return (inference.line, inference.formula, actualType)
            }
            
            formulas.append(contentsOf: assumptionsCorrected.formulaIndicesShifted(by: formulas.count))
        }
        
        return formulas
    }
}
