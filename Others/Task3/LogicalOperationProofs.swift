//
//  LogicalOperationProofProvider.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 15/11/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

struct BoolPair: Equatable, Hashable {
    let A: Bool
    let B: Bool
    
    public var hashValue: Int {
        return A.hashValue * 31 + B.hashValue
    }
    
    public static func == (lhs: BoolPair, rhs: BoolPair) -> Bool {
        return lhs.A == rhs.A && lhs.B == rhs.B
    }
}


let andProof: [BoolPair: [String]] = [
    BoolPair(A: true, B: true): [
        "A",
        "B",
        "A->B->A&B",
        "B->A&B",
        "A&B"
    ],
    BoolPair(A: true, B: false): [
        "!B",
        "(A&B->B)->(A&B->!B)->!(A&B)",
        "(A&B->B)",
        "(A&B->!B)->!(A&B)",
        "!B->(A&B)->!B",
        "(A&B)->!B",
        "!(A&B)"
    ],
    BoolPair(A: false, B: true): [
        "!A",
        "(A&B->A)->(A&B->!A)->!(A&B)",
        "(A&B->A)",
        "(A&B->!A)->!(A&B)",
        "!A->(A&B)->!A",
        "(A&B)->!A",
        "!(A&B)"
    ],
    BoolPair(A: false, B: false): [
        "!A",
        "(A&B->A)->(A&B->!A)->!(A&B)",
        "(A&B->A)",
        "(A&B->!A)->!(A&B)",
        "!A->(A&B)->!A",
        "(A&B)->!A",
        "!(A&B)"
    ]
]
