//
//  TaskList.swift
//  RealmApp
//
//  Created by Aleksei Voronovskii on 08.10.2021.
//  Copyright © 2021 Aleksei Voronovskii. All rights reserved.
//

import Foundation
import RealmSwift

class TaskList: Object {
    @Persisted var name = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}

class Task: Object {
    @Persisted var name = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplete = false
}
