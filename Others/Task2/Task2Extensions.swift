//
//  Extensions.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 14/11/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

extension Expression {
    func substituting(_ dict: [String : Expression]) -> Expression {
        switch self {
        case .variable(let value):
            return dict[value] ?? self
        case let .implication(lhs, rhs):
            return .implication(lhs.substituting(dict), rhs.substituting(dict))
        case let .disjunction(lhs, rhs):
            return .disjunction(lhs.substituting(dict), rhs.substituting(dict))
        case let .conjunction(lhs, rhs):
            return .conjunction(lhs.substituting(dict), rhs.substituting(dict))
        case .negation(let negated):
            return .negation(negated.substituting(dict))
        }
    }
}

extension Array where Element == FormulaInferenceType {
    func formulaIndicesShifted(by count: Int) -> [FormulaInferenceType] {
        return map {
            switch $0.type {
            case let .modusPonens(i, j):    return ($0.line, $0.formula, .modusPonens(i + count, j + count))
            default:                        return ($0.line, $0.formula, $0.type)
            }
        }
    }
}
