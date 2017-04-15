//
// Created by Abdukodiri Kurbonzoda on 06/08/16.
//

import Foundation

indirect enum LogicalExpression {
    case Implication(LogicalExpression, LogicalExpression)
    case Disjunction(LogicalExpression, LogicalExpression)
    case Conjunction(LogicalExpression, LogicalExpression)
    case Negation(LogicalExpression)
    case Variable(String)

    var description: String {
        switch self {
            case let .Implication(left, right):
                return "\(left.description) -> \(right.description)"
            case let .Disjunction(left, right):
                return "\(left.description) | \(right.description)"
            case let .Conjuction(left, right):
                return "\(left.description) & \(right.description)"
            case .Negation(let expression):
                return "!\(expression.description)"
            case .Variable(let value):
                return value;
        }
    }
}