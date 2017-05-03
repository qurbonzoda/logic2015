//
//  Task2All.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 03.05.17.
//  Copyright © 2017 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation




public indirect enum LogicalConnective {
    case implication(Formula, Formula)
    case disjunction(Formula, Formula)
    case conjunction(Formula, Formula)
    case negation(Formula)
    case variable(String)
}


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

private class FormulaParser {
    var formula: String
    var index: String.Index
    
    init(formula: String) {
        self.formula = formula.replacingOccurrences(of: " ", with: "")
        index = self.formula.startIndex
    }
    
    func parseImplication() -> Formula? {
        var result = parseDisjunction()
        while index != formula.endIndex && currentChar == "-" {
            advanceIndex()
            advanceIndex()
            result = Formula(.implication(result!, parseImplication()!))
        }
        return result
    }
    
    func parseDisjunction() -> Formula? {
        var result = parseConjunction()
        while index != formula.endIndex && currentChar == "|" {
            advanceIndex()
            result = Formula(.disjunction(result!, parseConjunction()!))
        }
        return result
    }
    
    func parseConjunction() -> Formula? {
        var result = parseNegation()
        while index != formula.endIndex && currentChar == "&" {
            advanceIndex()
            result = Formula(.conjunction(result!, parseNegation()!))
        }
        return result
    }
    
    func parseNegation() -> Formula? {
        var result = parseVariable()
        if index != formula.endIndex && currentChar == "(" {
            advanceIndex()
            result = parseImplication()
            advanceIndex()
        } else if index != formula.endIndex && currentChar == "!" {
            advanceIndex()
            result = Formula(.negation(parseNegation()!))
        }
        return result
    }
    
    func parseVariable() -> Formula? {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let digits = "0123456789"
        
        if letters.contains(currentChar) {
            var name = ""
            while index != formula.endIndex && (letters.contains(currentChar) || digits.contains(currentChar)) {
                name.append(currentChar)
                advanceIndex()
            }
            return Formula(.variable(name))
        }
        return nil
    }
    
    var currentChar: Character {
        return formula[index]
    }
    
    func advanceIndex() {
        index = formula.index(after: index)
    }
}


public extension String {
    func contains(_ character: Character) -> Bool {
        return contains(String(character))
    }
}



extension String {
    func toFormula() -> Formula {
        guard let parsedFormula = FormulaParser(formula: self).parseImplication() else {
            fatalError("Wrong formula format, formula: \(self)")
        }
        return parsedFormula
    }
}


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



public typealias Assumptions = [Formula]
public typealias Header = (gamma: Assumptions, inference: Formula)
public typealias InferenceFile = (header: Header, proof: [Formula])

private extension Array where Element == String {
    func removingEmptyFormulas() -> [Element] {
        return self
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}


func parse(fileAtPath filePath: String) throws -> InferenceFile {
    let content = try String(contentsOfFile: filePath, encoding: .utf8)
    
    let fileLines = content.components(separatedBy: .newlines).removingEmptyFormulas()
    let header = parse(header: fileLines.first!)
    let proof = fileLines.dropFirst().map { $0.toFormula() }
    
    assert(header.inference == proof.last, "The last statement of proof must be proof inference")
    
    return (header: header, proof: proof)
}

func parse(header: String) -> Header {
    let headerComponents = header.components(separatedBy: "|-")
    assert(headerComponents.count == 2, "Wrong header format: \(header)")
    
    let gamma = headerComponents.first!.components(separatedBy: ",")
        .removingEmptyFormulas()
        .map { $0.toFormula() }
    
    let inference = headerComponents.last!.toFormula()
    
    return (gamma: gamma, inference: inference)
}

func parse(proof: String) -> [Formula] {
    let proofLines = proof.components(separatedBy: .newlines).removingEmptyFormulas()
    return proofLines.map { $0.toFormula() }
}


typealias FormulaInferenceType = (line: Int, formula: Formula, type: InferenceType)

func validatePropositionalCalculusProve(inferenceFile: InferenceFile) -> [FormulaInferenceType] {
    let inference = inferenceFile.header.inference
    let proof = inferenceFile.proof
    
    var assumptionIndex = [Formula : Int]()
    inferenceFile.header.gamma.enumerated().forEach { assumptionIndex[$1] = $0 }
    
    var formulaIndex = Dictionary<Formula, Int>(minimumCapacity: proof.count * 5)
    var deducingsOfInference = Dictionary<Formula, [(index: Int, deducing: Formula)]>(minimumCapacity: proof.count * 5)
    let maxDeducingsCount = 20
    
    func modusPonensInference(of formula: Formula, from precedingFormulas: ArraySlice<Formula>) -> (Int, Int)? {
        guard let deducingsOfFormula = deducingsOfInference[formula] else {
            return nil
        }
        
        for deltaJ in deducingsOfFormula {
            if let deducingFormulaIndex = formulaIndex[deltaJ.deducing] {
                return (deducingFormulaIndex, deltaJ.index)
            }
        }
        
        if deducingsOfFormula.count < maxDeducingsCount {
            return nil
        }
        
        for precedingFormula in precedingFormulas.enumerated() {
            switch precedingFormula.element.unboxed {
            case let .implication(lhs, rhs) where rhs == formula:
                if let lhsIndex = formulaIndex[lhs] {
                    return (lhsIndex, precedingFormula.offset)
                }
            default:
                break
            }
        }
        return nil
    }
    
    assert(inference == proof.last!)
    
    var formulasInferenceTypes = [FormulaInferenceType]()
    
    for (index, formula) in proof.enumerated() {
        let inferenceType: InferenceType
        if let axiomNumber = axiomNumber(of: formula) {
            inferenceType = .axiom(axiomNumber)
        } else if let assumptionNumber = assumptionIndex[formula] {
            inferenceType = .assumption(assumptionNumber)
        } else if let mp = modusPonensInference(of: formula, from: proof.prefix(upTo: index)) {
            inferenceType = .modusPonens(mp.0, mp.1)
        } else {
            inferenceType = .notProven
        }
        formulasInferenceTypes.append((line: index, formula: formula, type: inferenceType))
        formulaIndex[formula] = index
        
        switch formula.unboxed {
        case let .implication(lhs, rhs):
            if deducingsOfInference[rhs] == nil {
                deducingsOfInference[rhs] = []
            }
            if deducingsOfInference[rhs]!.count < maxDeducingsCount {
                deducingsOfInference[rhs]!.append((index, lhs))
            }
        default:
            break
        }
    }
    return formulasInferenceTypes
}



enum InferenceType {
    case axiom(Int)
    case assumption(Int)
    case modusPonens(Int, Int)
    case notProven
    
    var description: String {
        switch self {
        case .axiom(let n):
            return "Сх. акс. \(n + 1)"
        case .assumption(let n):
            return "Предп. \(n + 1)"
        case .modusPonens(let i, let j):
            return "M.P. \(i + 1) \(j + 1)"
        case .notProven:
            return "Не доказано"
        }
    }
}

extension Formula {
    func substituting(_ dict: [String : Formula]) -> Formula {
        switch self.unboxed {
        case .variable(let value):
            return dict[value] ?? self
        case let .implication(lhs, rhs):
            return Formula(.implication(lhs.substituting(dict), rhs.substituting(dict)))
        case let .disjunction(lhs, rhs):
            return Formula(.disjunction(lhs.substituting(dict), rhs.substituting(dict)))
        case let .conjunction(lhs, rhs):
            return Formula(.conjunction(lhs.substituting(dict), rhs.substituting(dict)))
        case .negation(let negated):
            return Formula(.negation(negated.substituting(dict)))
        }
    }
}

extension Array where Element == FormulaInferenceType {
    func formulaIndicesShifted(by count: Int) -> [FormulaInferenceType] {
        return map {
            switch $0.type {
            case let .modusPonens(i, j):    return ($0.line, $0.formula, .modusPonens(i + count, j + count))
            default:                        return ($0.line, $0.formula, $0.type)
            }
        }
    }
}

func proofDeduction(header: Header, proof: [FormulaInferenceType]) -> [FormulaInferenceType] {
    assert(header.gamma.count > 0)
    assert(proof.count > 0)
    assert(header.inference == proof.last!.formula)
    
    let alpha = header.gamma.last!
    
    var deductionProof = [FormulaInferenceType]()
    var formulaNewIndex = [Int]()
    
    //    let badFormula = "(b->c)"
    
    for inference in proof {
        let precedingFormulas: [FormulaInferenceType]
        
        if inference.formula == alpha {
            precedingFormulas = [
                (0, "A->(A->A)",                                .axiom(0)),
                (1, "(A->(A->A))->(A->((A->A)->A))->(A->A)",    .axiom(1)),
                (2, "(A->((A->A)->A))->(A->A)",                 .modusPonens(0, 1)),
                (3, "(A->((A->A)->A))",                         .axiom(0)),
                (4, "A->A",                                     .modusPonens(3, 2))
                ]
                .map { ($0.0, $0.1.toFormula().substituting(["A": alpha]), $0.2) }
        } else {
            switch inference.type {
            case .axiom(let i):
                precedingFormulas = [
                    (0, "A",            .axiom(i)),
                    (1, "A->(B->A)",    .axiom(0)),
                    (2, "B->A",         .modusPonens(0, 1))
                    ]
                    .map { ($0.0, $0.1.toFormula().substituting(["A": inference.formula, "B": alpha]), $0.2) }
                
            case .assumption(let i):
                //                assert(header.gamma[i] == inference.formula)
                precedingFormulas = [
                    (0, "A",            .assumption(i)),
                    (1, "A->(B->A)",    .axiom(0)),
                    (2, "B->A",         .modusPonens(0, 1))
                    ]
                    .map { ($0.0, $0.1.toFormula().substituting(["A": inference.formula, "B": alpha]), $0.2) }
                
            case .modusPonens(let j, let k):
                precedingFormulas = [
                    (0, "(A->B)->(A->(B->C))->(A->C)",  .axiom(1)),
                    (1, "(A->(B->C))->(A->C)",          .modusPonens(formulaNewIndex[j] - deductionProof.count, 0)),
                    (2, "A->C",                         .modusPonens(formulaNewIndex[k] - deductionProof.count, 1))
                    ]
                    .map { ($0.0, $0.1.toFormula().substituting(["A": alpha, "B": proof[j].formula, "C": inference.formula]), $0.2) }
                
            case .notProven:
                fatalError("The proof must be correct to do deduction")
            }
        }
        
        //        if (precedingFormulas.contains(where: { $0.formula.description == badFormula })) {
        //            print(precedingFormulas.reduce("") { $0 + "\r" + $1.formula.description })
        //        }
        
        deductionProof.append(contentsOf: precedingFormulas.formulaIndicesShifted(by: deductionProof.count))
        formulaNewIndex.append(deductionProof.count - 1)
    }
    
    //    validate(gamma: Array(header.gamma.dropLast()), inference: Formula(.implication(alpha, header.inference)), inferenceProof: deductionProof)
    
    return deductionProof
}

private func validate(gamma: [Formula], inference: Formula, inferenceProof: [FormulaInferenceType]) {
    let inferenceFile = (header: (gamma: gamma, inference: inference),
                         proof: inferenceProof.map { $0.formula })
    let validation = validatePropositionalCalculusProve(inferenceFile: inferenceFile)
    
    print("################\r\r" + validation
        .map { "(\($0.line + 1)) \($0.formula.description) (\($0.type.description))" }
        .reduce("") { $0 + $1 + "\r" })
    
    assert(!validation.contains {
        switch $0.type {
        case .notProven:    return true
        default:            return false
        }
        })
}


private let testsDirectory = "/Users/bigdreamer/Programming/logic2015/Others/Task2/Tests/"

do {
    let inputTests = try FileManager().contentsOfDirectory(atPath: testsDirectory).filter { $0.hasSuffix(".in") }
    
    for var inputPath in inputTests {
        inputPath = testsDirectory + inputPath
        let outputPath = inputPath.replacingOccurrences(of: ".in", with: ".out")
        
        let inferenceFile = try parse(fileAtPath: inputPath)
        let inferenceTypes = validatePropositionalCalculusProve(inferenceFile: inferenceFile)
        
        try proofDeduction(header: inferenceFile.header, proof: inferenceTypes)
            .reduce("", { $0 + $1.formula.description + "\n" })
            .write(toFile: outputPath, atomically: false, encoding: .utf8)
        
    }
} catch {
    print("an error occured, cause: \(error)")
}
