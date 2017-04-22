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
].map { $0.toFormula() }

func isAxiom(_ formula: Formula) -> Bool {
    return axioms.contains(where: { formula.conformsTo(axiom: $0) })
}

func axiomNumber(of formula: Formula) -> Int? {
    return axioms.enumerated().first { formula.conformsTo(axiom: $0.element) }?.offset
}

