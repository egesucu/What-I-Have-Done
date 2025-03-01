//
//  ActivityExtensions.swift
//  What I Have Done
//
//  Created by Sucu, Ege on 1.03.2025.
//

import Foundation
import CoreData

extension Activity {
    var category: ActivityCategory {
        get {
            return ActivityCategory(
                rawValue: categoryRaw ?? ActivityCategory.other.rawValue
            ) ?? .other
        }
        set {
            categoryRaw = newValue.rawValue
        }
    }
}
