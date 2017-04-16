//
// Created by Abdukodiri Kurbonzoda on 06/08/16.
//

import Foundation

public typealias Assumptions = [Expression]
public typealias Header = (gamma: Assumptions, inference: Expression)
public typealias InferenceFile = (header: Header, proof: [Expression])

private extension Array where Element == String {
    func removingEmptyExpressions() -> [Element] {
        return self
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

extension String {
    func toExpression() -> Expression {
        guard let parsedExpression = ExpressionParser(expression: self).parseImplication() else {
            fatalError("Wrong expression format, expression: \(self)")
        }
        return parsedExpression
    }
}

func parse(fileAtPath filePath: String) throws -> InferenceFile {
    let content = try String(contentsOfFile: filePath, encoding: .utf8)
    
    let fileLines = content.components(separatedBy: .newlines).removingEmptyExpressions()
    let header = parse(header: fileLines.first!)
    let proof = fileLines.dropFirst().map { $0.toExpression() }
    
    assert(header.inference == proof.last, "The last statement of proof must be proof inference")
    
    return (header: header, proof: proof)
}

func parse(header: String) -> Header {
    let headerComponents = header.components(separatedBy: "|-")
    assert(headerComponents.count == 2, "Wrong header format: \(header)")
    
    let gamma = headerComponents.first!.components(separatedBy: ",")
            .removingEmptyExpressions()
            .map { $0.toExpression() }
    
    let inference = headerComponents.last!.toExpression()
    
    return (gamma: gamma, inference: inference)
}

func parse(proof: String) -> [Expression] {
    let proofLines = proof.components(separatedBy: .newlines).removingEmptyExpressions()
    return proofLines.map { $0.toExpression() }
}

private class ExpressionParser {
    var expression: String
    var index: String.Index
    
    init(expression: String) {
        self.expression = expression.replacingOccurrences(of: " ", with: "")
        index = self.expression.startIndex
    }
    
    func parseImplication() -> Expression? {
        var result = parseDisjunction()
        while index != expression.endIndex && expression[index] == "-" {
            advanceIndex()
            advanceIndex()
            result = .implication(result!, parseImplication()!)
        }
        return result
    }
    
    func parseDisjunction() -> Expression? {
        var result = parseConjunction()
        while index != expression.endIndex && expression[index] == "|" {
            advanceIndex()
            result = .disjunction(result!, parseConjunction()!)
        }
        return result
    }
    
    func parseConjunction() -> Expression? {
        var result = parseNegation()
        while index != expression.endIndex && expression[index] == "&" {
            advanceIndex()
            result = .conjunction(result!, parseNegation()!)
        }
        return result
    }
    
    func parseNegation() -> Expression? {
        var result = parseVariable()
        if index != expression.endIndex && expression[index] == "(" {
            advanceIndex()
            result = parseImplication()
            advanceIndex()
        } else if index != expression.endIndex && expression[index] == "!" {
            advanceIndex()
            result = .negation(parseNegation()!)
        }
        return result
    }
    
    func parseVariable() -> Expression? {
        let alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let letters = alpha + alpha.lowercased()
        let digits = "0123456789"
        
        if letters.contains(expression[index]) {
            var name = ""
            while index != expression.endIndex && (letters.contains(expression[index]) || digits.contains(expression[index])) {
                name.append(expression[index])
                advanceIndex()
            }
            return .variable(name)
        }
        return nil
    }
    
    func advanceIndex() {
        index = expression.index(after: index)
    }
}
