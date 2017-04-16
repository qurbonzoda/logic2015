//
//  LogicalOperationProof.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 15/11/16.
//  Copyright © 2016 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

public struct BoolPair: Equatable, Hashable {
    let A: Bool
    let B: Bool
    
    public var hashValue: Int {
        return A.hashValue * 31 + B.hashValue
    }
    
    public static func == (lhs: BoolPair, rhs: BoolPair) -> Bool {
        return lhs.A == rhs.A && lhs.B == rhs.B
    }
}

private extension Array where Element == (BoolPair, [FormulaInferenceType]) {
    func toDictionary() -> [BoolPair: [FormulaInferenceType]] {
        var dictionary = [BoolPair: [FormulaInferenceType]]()
        forEach { dictionary[$0.0] = $0.1 }
        return dictionary
    }
}

private extension Array where Element == (Bool, [FormulaInferenceType]) {
    func toDictionary() -> [Bool: [FormulaInferenceType]] {
        var dictionary = [Bool: [FormulaInferenceType]]()
        forEach { dictionary[$0.0] = $0.1 }
        return dictionary
    }
}

private extension Array where Element == String {
    func validated() -> [FormulaInferenceType] {
        let header = "|-A|!A"
        let proof = reduce("") { $0 + "\r" + $1 }
        let inferenceFile = (parse(header: header), parse(proof: proof))
        return validatePropositionalCalculusProve(inferenceFile: inferenceFile)
    }
}

private extension Dictionary where Key == BoolPair, Value == [String] {
    func validated() -> [BoolPair: [FormulaInferenceType]] {
        return map { (key: BoolPair, value: [String]) -> (BoolPair, [FormulaInferenceType]) in
            let header = (key.A ? "A" : "!A") + "," + (key.B ? "B" : "!B") + "|-" + value.last!
            let proof = value.reduce("") { $0 + "\r" + $1 }
            let inferenceFile = (parse(header: header), parse(proof: proof))
            return (key, validatePropositionalCalculusProve(inferenceFile: inferenceFile))
        }.toDictionary()
    }
}

private extension Dictionary where Key == Bool, Value == [String] {
    func validated() -> [Bool: [FormulaInferenceType]] {
        return map { (key: Bool, value: [String]) -> (Bool, [FormulaInferenceType]) in
            let header = (key ? "A" : "!A") + "|-" + value.last!
            let proof = value.reduce("") { $0 + "\r" + $1 }
            let inferenceFile = (parse(header: header), parse(proof: proof))
            return (key, validatePropositionalCalculusProve(inferenceFile: inferenceFile))
            }.toDictionary()
    }
}


let conjunctionProof: [BoolPair: [FormulaInferenceType]] = [
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
].validated()


let disjunctionProof: [BoolPair: [FormulaInferenceType]] = [
    BoolPair(A: true, B: true): [
        "A",
        "A->A|B",
        "A|B"
    ],
    BoolPair(A: true, B: false): [
        "A",
        "A->A|B",
        "A|B"
    ],
    BoolPair(A: false, B: true): [
        "B",
        "B->A|B",
        "A|B"
    ],
    BoolPair(A: false, B: false): [
        "!A",
        "!B",
        "(A|B->A)->(A|B->!A)->!(A|B)",
        "(A->A)->(B->A)->(A|B->A)",
        "A->A->A",
        "(A->A->A)->(A->(A->A)->A)->(A->A)",
        "(A->(A->A)->A)->(A->A)",
        "A->(A->A)->A",
        "A->A",
        "(B->A)->(A|B->A)",
        "!B->B->!B",
        "B->!B",
        "B->B->B",
        "(B->B->B)->(B->(B->B)->B)->B->B",
        "(B->(B->B)->B)->B->B",
        "(B->(B->B)->B)",
        "B->B",
        "(!!A->A)",
        "(!!A->A)->B->(!!A->A)",
        "B->(!!A->A)",
        "((!A->B)->(!A->!B)->!!A)",
        "((!A->B)->(!A->!B)->!!A)->B->((!A->B)->(!A->!B)->!!A)",
        "B->((!A->B)->(!A->!B)->!!A)",
        "(B->!A->B)",
        "(B->!A->B)->B->(B->!A->B)",
        "B->(B->!A->B)",
        "(B->B)->(B->B->(!A->B))->B->(!A->B)",
        "(B->B->(!A->B))->B->(!A->B)",
        "B->(!A->B)",
        "(B->(!A->B))->(B->(!A->B)->((!A->!B)->!!A))->B->((!A->!B)->!!A)",
        "(B->(!A->B)->((!A->!B)->!!A))->B->((!A->!B)->!!A)",
        "B->((!A->!B)->!!A)",
        "(!B->!A->!B)",
        "(!B->!A->!B)->B->(!B->!A->!B)",
        "B->(!B->!A->!B)",
        "(B->!B)->(B->!B->(!A->!B))->B->(!A->!B)",
        "(B->!B->(!A->!B))->B->(!A->!B)",
        "B->(!A->!B)",
        "(B->(!A->!B))->(B->(!A->!B)->!!A)->B->!!A",
        "(B->(!A->!B)->!!A)->B->!!A",
        "B->!!A",
        "(B->!!A)->(B->!!A->A)->B->A",
        "(B->!!A->A)->B->A",
        "B->A",
        "A|B->A",
        "(A|B->!A)->!(A|B)",
        "!A->A|B->!A",
        "A|B->!A",
        "!(A|B)"
    ]
].validated()


let implicationProof: [BoolPair: [FormulaInferenceType]] = [
    BoolPair(A: true, B: true): [
        "B",
        "B->A->B",
        "A->B"
    ],
    BoolPair(A: true, B: false): [
        "A",
        "!B",
        "((A->B)->B)->((A->B)->!B)->!(A->B)",
        "A->(A->B)->A",
        "(A->B)->A",
        "(A->B)->(A->B)->(A->B)",
        "(A->B)->((A->B)->(A->B))->(A->B)",
        "((A->B)->(A->B)->(A->B))->((A->B)->((A->B)->(A->B))->(A->B))->((A->B)->(A->B))",
        "((A->B)->((A->B)->(A->B))->(A->B))->((A->B)->(A->B))",
        "(A->B)->(A->B)",
        "((A->B)->A)->((A->B)->A->B)->((A->B)->B)",
        "((A->B)->A->B)->((A->B)->B)",
        "((A->B)->B)",
        "((A->B)->!B)->!(A->B)",
        "!B->(A->B)->!B",
        "(A->B)->!B",
        "!(A->B)"
    ],
    BoolPair(A: false, B: true): [
        "B",
        "B->A->B",
        "A->B"
    ],
    BoolPair(A: false, B: false): [
        "!A",
        "!A->A->!A",
        "A->!A",
        "!B",
        "!B->A->!B",
        "A->!B",
        "A->A->A",
        "(A->A->A)->(A->(A->A)->A)->A->A",
        "(A->(A->A)->A)->A->A",
        "(A->(A->A)->A)",
        "A->A",
        "(A -> !B -> A)",
        "(A -> !B -> A)->A->(A -> !B -> A)",
        "A->(A -> !B -> A)",
        "(A->A)->(A->A->(!B->A))->A->(!B->A)",
        "(A->A->(!B->A))->A->(!B->A)",
        "A->(!B->A)",
        "(!A -> !B -> !A)",
        "(!A -> !B -> !A)->A->(!A -> !B -> !A)",
        "A->(!A -> !B -> !A)",
        "(A->!A)->(A->!A->(!B->!A))->A->(!B->!A)",
        "(A->!A->(!B->!A))->A->(!B->!A)",
        "A->(!B->!A)",
        "((!B -> A) -> (!B -> !A) -> !!B)",
        "((!B -> A) -> (!B -> !A) -> !!B)->A->((!B -> A) -> (!B -> !A) -> !!B)",
        "A->((!B -> A) -> (!B -> !A) -> !!B)",
        "(A->(!B->A))->(A->(!B->A)->((!B -> !A) -> !!B))->A->((!B -> !A) -> !!B)",
        "(A->(!B->A)->((!B -> !A) -> !!B))->A->((!B -> !A) -> !!B)",
        "A->((!B -> !A) -> !!B)",
        "(A->(!B->!A))->(A->(!B->!A)->!!B)->A->!!B",
        "(A->(!B->!A)->!!B)->A->!!B",
        "A->!!B",
        "(!!B->B)",
        "(!!B->B)->A->(!!B->B)",
        "A->(!!B->B)",
        "(A->!!B)->(A->!!B->B)->A->B",
        "(A->!!B->B)->A->B",
        "A->B"
    ]
].validated()


let negationProof: [Bool: [FormulaInferenceType]] = [
    true: [
        "A",
        "(!A->A)->(!A->!A)->!!A",
        "A->!A->A",
        "!A->A",
        "(!A->!A)->!!A",
        "!A->!A->!A",
        "(!A->!A->!A)->(!A->(!A->!A)->!A)->(!A->!A)",
        "(!A->(!A->!A)->!A)->(!A->!A)",
        "!A->(!A->!A)->!A",
        "!A->!A",
        "!!A"
    ],
    false: [
        "!A"
    ]
].validated()


let variableProof: [Bool: [FormulaInferenceType]] = [
    true: [
        "A"
    ],
    false: [
        "!A"
    ]
].validated()

let aOrNotAProof: [FormulaInferenceType] = [
    "A->A|!A",
    "(((A->(A|!A))->((A->!(A|!A))->!A))->(!(A|!A)->((A->(A|!A))->((A->!(A|!A))->!A))))",
    "((A->(A|!A))->((A->!(A|!A))->!A))",
    "(!(A|!A)->((A->(A|!A))->((A->!(A|!A))->!A)))",
    "((A->(A|!A))->(!(A|!A)->(A->(A|!A))))",
    "(A->(A|!A))",
    "(!(A|!A)->(A->(A|!A)))",
    "((!(A|!A)->(A->(A|!A)))->((!(A|!A)->((A->(A|!A))->((A->!(A|!A))->!A)))->(!(A|!A)->((A->!(A|!A))->!A))))",
    "((!(A|!A)->((A->(A|!A))->((A->!(A|!A))->!A)))->(!(A|!A)->((A->!(A|!A))->!A)))",
    "(!(A|!A)->((A->!(A|!A))->!A))",
    "((!(A|!A)->(A->!(A|!A)))->(!(A|!A)->(!(A|!A)->(A->!(A|!A)))))",
    "(!(A|!A)->(A->!(A|!A)))",
    "(!(A|!A)->(!(A|!A)->(A->!(A|!A))))",
    "(!(A|!A)->(!(A|!A)->!(A|!A)))",
    "((!(A|!A)->(!(A|!A)->!(A|!A)))->((!(A|!A)->((!(A|!A)->!(A|!A))->!(A|!A)))->(!(A|!A)->!(A|!A))))",
    "((!(A|!A)->((!(A|!A)->!(A|!A))->!(A|!A)))->(!(A|!A)->!(A|!A)))",
    "(!(A|!A)->((!(A|!A)->!(A|!A))->!(A|!A)))",
    "(!(A|!A)->!(A|!A))",
    "((!(A|!A)->!(A|!A))->((!(A|!A)->(!(A|!A)->(A->!(A|!A))))->(!(A|!A)->(A->!(A|!A)))))",
    "((!(A|!A)->(!(A|!A)->(A->!(A|!A))))->(!(A|!A)->(A->!(A|!A))))",
    "(!(A|!A)->(A->!(A|!A)))",
    "((!(A|!A)->(A->!(A|!A)))->((!(A|!A)->((A->!(A|!A))->!A))->(!(A|!A)->!A)))",
    "((!(A|!A)->((A->!(A|!A))->!A))->(!(A|!A)->!A))",
    "(!(A|!A)->!A)",
    "!A->A|!A",
    "(((!A->(A|!A))->((!A->!(A|!A))->!!A))->(!(A|!A)->((!A->(A|!A))->((!A->!(A|!A))->!!A))))",
    "((!A->(A|!A))->((!A->!(A|!A))->!!A))",
    "(!(A|!A)->((!A->(A|!A))->((!A->!(A|!A))->!!A)))",
    "((!A->(A|!A))->(!(A|!A)->(!A->(A|!A))))",
    "(!A->(A|!A))",
    "(!(A|!A)->(!A->(A|!A)))",
    "((!(A|!A)->(!A->(A|!A)))->((!(A|!A)->((!A->(A|!A))->((!A->!(A|!A))->!!A)))->(!(A|!A)->((!A->!(A|!A))->!!A))))",
    "((!(A|!A)->((!A->(A|!A))->((!A->!(A|!A))->!!A)))->(!(A|!A)->((!A->!(A|!A))->!!A)))",
    "(!(A|!A)->((!A->!(A|!A))->!!A))",
    "((!(A|!A)->(!A->!(A|!A)))->(!(A|!A)->(!(A|!A)->(!A->!(A|!A)))))",
    "(!(A|!A)->(!A->!(A|!A)))",
    "(!(A|!A)->(!(A|!A)->(!A->!(A|!A))))",
    "(!(A|!A)->(!(A|!A)->!(A|!A)))",
    "((!(A|!A)->(!(A|!A)->!(A|!A)))->((!(A|!A)->((!(A|!A)->!(A|!A))->!(A|!A)))->(!(A|!A)->!(A|!A))))",
    "((!(A|!A)->((!(A|!A)->!(A|!A))->!(A|!A)))->(!(A|!A)->!(A|!A)))",
    "(!(A|!A)->((!(A|!A)->!(A|!A))->!(A|!A)))",
    "(!(A|!A)->!(A|!A))",
    "((!(A|!A)->!(A|!A))->((!(A|!A)->(!(A|!A)->(!A->!(A|!A))))->(!(A|!A)->(!A->!(A|!A)))))",
    "((!(A|!A)->(!(A|!A)->(!A->!(A|!A))))->(!(A|!A)->(!A->!(A|!A))))",
    "(!(A|!A)->(!A->!(A|!A)))",
    "((!(A|!A)->(!A->!(A|!A)))->((!(A|!A)->((!A->!(A|!A))->!!A))->(!(A|!A)->!!A)))",
    "((!(A|!A)->((!A->!(A|!A))->!!A))->(!(A|!A)->!!A))",
    "(!(A|!A)->!!A)",
    "(!(A|!A)->!A)->(!(A|!A)->!!A)->!!(A|!A)",
    "(!(A|!A)->!!A)->!!(A|!A)",
    "!!(A|!A)",
    "!!(A|!A)->(A|!A)",
    "A|!A"
].validated()

