//
//  Axioms.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 17/09/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

let axioms = [
    "A->B->A",
    "(A->B)->(A->(B->C))->(A->C)",
    "A&B->A",
    "A&B->B",
    "A->(B->A&B)",
    "A->A|B",
    "B->A|B",
    "(A->C)->(B->C)->(A|B->C)",
    "(A->C)->(A->!C)->!A",
    "!!A->A"
].map { $0.toExpression() }

func isAxiom(_ expression: Expression) -> Bool {
    return axioms.contains(where: { expression.conformsTo(axiom: $0) })
}

func axiomNumber(of expression: Expression) -> Int? {
    return axioms.enumerated().first { expression.conformsTo(axiom: $0.element) }?.offset
}

