//
// Created by Abdukodiri Kurbonzoda on 06/08/16.
//

import Foundation

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

extension String {
    func toFormula() -> Formula {
        guard let parsedFormula = FormulaParser(formula: self).parseImplication() else {
            fatalError("Wrong formula format, formula: \(self)")
        }
        return parsedFormula
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
