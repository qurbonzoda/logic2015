//
// Created by Abdukodiri Kurbonzoda on 06/08/16.
//

import Foundation


public struct Formula {
    public let unboxed: LogicalConnective
    public let description: String
    public let hashValue: Int
    
    init(_ connective: LogicalConnective) {
        unboxed = connective
        
        switch unboxed {
        case let .implication(left, right):
            description = "(\(left.description)->\(right.description))"
        case let .disjunction(left, right):
            description = "(\(left.description)|\(right.description))"
        case let .conjunction(left, right):
            description = "(\(left.description)&\(right.description))"
        case .negation(let expression):
            description = "!\(expression.description)"
        case .variable(let value):
            description = value
        }
        
        hashValue = description.hashValue
    }
}


extension Formula : CustomStringConvertible {}

extension Formula : Hashable {}

extension Formula: Equatable {
    public static func == (lhs: Formula, rhs: Formula) -> Bool {
        return lhs.hashValue == rhs.hashValue && lhs.description == rhs.description
    }
}
