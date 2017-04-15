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
    
    func lines() -> [String] {
        var lines = [String]()
        enumerateLines { (line: String, flag: inout Bool) in
            lines.append(line)
        }
        return lines
    }
    
    static func fromFile(path: String) throws -> String {
        return try self.init(contentsOfFile: "/Users/bigdreamer/Programming/logic2015/Others/Others/axioms.txt", encoding: .utf8)
    }
}

public extension LogicalExpression {
    func conformsTo(axiom: LogicalExpression) -> Bool {
        var mapping = [String : LogicalExpression]()
        
        func check(_ first: LogicalExpression, and second: LogicalExpression) -> Bool {
            switch (first, second) {
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
