//
//  Extensions.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 14/11/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

extension Expression: Hashable {
    public var hashValue: Int {
        return self.description.hashValue
    }
}

extension Expression {
    func evaluate(considering dict: [Expression: Bool]) -> Bool {
        switch self {
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
    
    func distinctVariables() -> [Expression] {
        var variables = Set<Expression>()
        
        self.forEach {
            switch $0 {
            case .variable(_):
                variables.insert($0)
            default:
                break
            }
        }
        
        return Array(variables)
    }
    
    private func forEach(_ body: (Expression) -> Void) {
        switch self {
        case .variable(_):
            break
        case .implication(let lhs, let rhs),
             .disjunction(let lhs, let rhs),
             .conjunction(let lhs, let rhs):
            lhs.forEach(body)
            rhs.forEach(body)
        case .negation(let negated):
            negated.forEach(body)
        }
        
        body(self)
    }
    
    func proof(considering dict: [Expression: Bool]) -> [Expression] {
        var formula = [Expression]()
        
        self.forEach {
            switch $0 {
            case .variable(_):
                let variable = $0
                variableProof[variable.evaluate(considering: dict)]!.forEach {
                    formula.append($0.toExpression().substituting(["A": variable]))
                }
            case let .implication(lhs, rhs):
                implicationProof[BoolPair(A: lhs.evaluate(considering: dict), B: rhs.evaluate(considering: dict))]!.forEach {
                    formula.append($0.toExpression().substituting(["A": lhs, "B": rhs]))
                }
            case let .disjunction(lhs, rhs):
                disjunctionProof[BoolPair(A: lhs.evaluate(considering: dict), B: rhs.evaluate(considering: dict))]!.forEach {
                    formula.append($0.toExpression().substituting(["A": lhs, "B": rhs]))
                }
            case let .conjunction(lhs, rhs):
                conjunctionProof[BoolPair(A: lhs.evaluate(considering: dict), B: rhs.evaluate(considering: dict))]!.forEach {
                    formula.append($0.toExpression().substituting(["A": lhs, "B": rhs]))
                }
            case .negation(let negated):
                negationProof[negated.evaluate(considering: dict)]!.forEach {
                    formula.append($0.toExpression().substituting(["A": negated]))
                }
            }
        }
        
        return formula
    }
}
