//
//  ContentView.swift
//  SwiperPicsumExample
//
//  Created by Silbino Gonçalves Matado on 2023-05-22.
//

import SwiftUI
import Swiper

struct ContentView: View {
    
    @State var items: [CardModel] = (0...1000).map { CardModel(id: $0) }
    
    var body: some View {
        Swiper(data: $items) { item, action in
            CardView(cardModel: item, userAction: action)
        } onSwipe: { item, action in
            print("Swiped \(action) on item id \(item.id)")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
