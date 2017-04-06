//
//  GridCell.swift
//  MazeMan
//
//  Created by Ben on 4/6/17.
//  Copyright © 2017 Benjamin Leach. All rights reserved.
//

import Foundation
import GameplayKit

class GridCell {
    
    var location = CGPoint()
    var occupied = Bool()
    var intID = Int()
    
    init(_ loc: CGPoint, _ occupy: Bool, _ id: Int) {
        location = loc
        occupied = occupy
        intID = id
    }
}
