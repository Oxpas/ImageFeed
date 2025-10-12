//
//  Array.swift
//  Image Feed
//
//  Created by Николай Замараев on 04.10.2025.
//

import Foundation

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}
