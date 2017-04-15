//
// Created by Abdukodiri Kurbonzoda on 06/08/16.
//

import Foundation

public indirect enum Expression {
    case implication(Expression, Expression)
    case disjunction(Expression, Expression)
    case conjunction(Expression, Expression)
    case negation(Expression)
    case variable(String)

    var description: String {
        switch self {
            case let .implication(left, right):
                return "(\(left.description) -> \(right.description))"
            case let .disjunction(left, right):
                return "(\(left.description) | \(right.description))"
            case let .conjunction(left, right):
                return "\(left.description) & \(right.description)"
            case .negation(let expression):
                return "!\(expression.description)"
            case .variable(let value):
                return value
        }
    }
    
    static func == (lhs: Expression, rhs: Expression) -> Bool {
        return lhs.description == rhs.description
    }
}
