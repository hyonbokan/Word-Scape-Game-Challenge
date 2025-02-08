//
//  WordModel.swift
//  WordScapeGame
//
//  Created by Khen Bo on 2/6/25.
//

import Foundation

struct WordModel {
    let text: String
    let speedPercentage: CGFloat = CGFloat.random(in: 0.3...0.8)
}
