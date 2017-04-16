//
//  InferenceType.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 15.04.17.
//  Copyright © 2017 Abdukodiri Kurbonzoda. All rights reserved.
//

import Foundation

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
