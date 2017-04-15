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
}
