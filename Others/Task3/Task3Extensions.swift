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
    
    
    public func forEach(_ body: (Expression) -> Void) {
        body(self)
        
        switch self {
        case .variable(_):
            break
        case let .implication(lhs, rhs),
             .disjunction(lhs, rhs),
             .conjunction(lhs, rhs):
            lhs.forEach(body)
            rhs.forEach(body)
        case .negation(let negated):
            negated.forEach(body)
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
}
