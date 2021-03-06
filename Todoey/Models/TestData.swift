//
//  TestData.swift
//  Todoey
//
//  Created by Elliot Hannah III on 3/5/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class RealmTest: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}
