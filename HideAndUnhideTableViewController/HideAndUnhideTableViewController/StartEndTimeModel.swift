//
//  StartEndTimeModel.swift
//  Fynd
//
//  Created by ShrawanKumar Sharma on 27/04/17.
//  Copyright © 2017 Fynd. All rights reserved.
//

import Foundation


class StartEndTimeModel {
    
    var startDate:Date!
    var endDate:Date!

    init (startDate: Date? , finishDate:Date){
        self.startDate = startDate
        self.endDate = finishDate
    }
    
}
