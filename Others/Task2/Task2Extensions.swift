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
