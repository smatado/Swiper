//
//  ContentView.swift
//  SwiperPicsumExample
//
//  Created by Silbino Gonçalves Matado on 2023-05-22.
//

import SwiftUI
import Swiper

struct ContentView: View {
    
    @State var items: [CardModel] = (10...1000).map { CardModel(id: $0) }
    @State var showButtonBarInCard: Bool = false
    @State var lastSwipedDirection: Edge?
    @State private var swipeStackProxy = SwipeStackProxy()
    
    var body: some View {
        VStack(spacing: 16.0) {
            Toggle(isOn: $showButtonBarInCard, label: {
                Text("Show Button Bar In Card")
            })
            
            SwipeStack(data: $items, proxy: $swipeStackProxy) { item, swipeDirection in
                CardView(
                    cardModel: item,
                    swipeDirection: swipeDirection,
                    showButtonBarInCard: $showButtonBarInCard,
                    lastSwipedDirection: $lastSwipedDirection,
                    swipeStackProxy: $swipeStackProxy
                )
            } onSwipe: { swipeDirection in
                print("Swiped = \(swipeDirection)")
            } onRollback: { rollbackDirection in
                print("Rollback = \(rollbackDirection)")
            }
            .zIndex(1)
            
            if !showButtonBarInCard {
                ButtonBar(lastSwipedDirection: $lastSwipedDirection, swipeStackProxy: $swipeStackProxy)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
