//
//  CardModel.swift
//  Swipe
//
//  Created by Silbino Gonçalves Matado on 2023-04-22.
//

import Foundation

struct CardModel: Identifiable, Equatable {
    var id: Int
    
    init(id: Int) {
        self.id = id
    }
}
