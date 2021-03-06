//
//  Extensions.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 06/08/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

public extension String {
    func contains(_ character: Character) -> Bool {
        return contains(String(character))
    }
}

public extension Formula {
    func conformsTo(axiom: Formula) -> Bool {
        var mapping = [String : Formula]()
        
        func check(_ first: Formula, and second: Formula) -> Bool {
            switch (first.unboxed, second.unboxed) {
            case let (.implication(firstLhs, firstRhs), .implication(secondLhs, secondRhs)),
                 let (.disjunction(firstLhs, firstRhs), .disjunction(secondLhs, secondRhs)),
                 let (.conjunction(firstLhs, firstRhs), .conjunction(secondLhs, secondRhs)):
                return check(firstLhs, and: secondLhs) && check(firstRhs, and: secondRhs)
                
            case let (.negation(firstExpression), .negation(secondExpression)):
                return check(firstExpression, and: secondExpression)
                
            case (.variable(let variable), _):
                if let reflection = mapping[variable] {
                    return reflection == second
                }
                mapping[variable] = second
                return true
                
            default:
                return false
            }
        }
        
        return check(axiom, and: self)
    }
}
