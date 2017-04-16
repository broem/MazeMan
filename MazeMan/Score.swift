//
//  Score.swift
//  MazeMan
//
//  Created by Ben on 4/11/17.
//  Copyright © 2017 Benjamin Leach. All rights reserved.
//

import Foundation

class Score: NSObject, NSCoding {
    
    var score = Int()
    
    init(_ sc: Int) {
        score = sc
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(score, forKey: "score")
    }
    required init?(coder aDecoder: NSCoder) {
        score = aDecoder.decodeInteger(forKey: "score")
    }

    
}
