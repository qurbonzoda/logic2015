//
//  LogicalConnective.swift
//  Others
//
//  Created by Abdukodiri Kurbonzoda on 22.04.17.
//  Copyright © 2017 Abdukodiri Kurbonzoda. All rights reserved.
//


public indirect enum LogicalConnective {
    case implication(Formula, Formula)
    case disjunction(Formula, Formula)
    case conjunction(Formula, Formula)
    case negation(Formula)
    case variable(String)
}
