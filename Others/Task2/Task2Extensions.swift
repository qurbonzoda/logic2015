//
//  Extensions.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 14/11/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

extension Formula {
    func substituting(_ dict: [String : Formula]) -> Formula {
        switch self.unboxed {
        case .variable(let value):
            return dict[value] ?? self
        case let .implication(lhs, rhs):
            return Formula(.implication(lhs.substituting(dict), rhs.substituting(dict)))
        case let .disjunction(lhs, rhs):
            return Formula(.disjunction(lhs.substituting(dict), rhs.substituting(dict)))
        case let .conjunction(lhs, rhs):
            return Formula(.conjunction(lhs.substituting(dict), rhs.substituting(dict)))
        case .negation(let negated):
            return Formula(.negation(negated.substituting(dict)))
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
