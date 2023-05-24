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
        Swiper(data: $items) { item, action, _ in
            CardView(cardModel: item, userAction: action)
                .shadow(radius: 4.0, x: 4.0, y: 4.0)
        } buttons: { context in
            HStack {
                Spacer()
                Button {
                    context.dislike()
                } label: {
                    Image(systemName: "hand.thumbsdown.circle")
                        .resizable()
                        .tint(.red)
                        .frame(width: 64.0, height: 64.0)
                }
                Spacer()
                Button {
                    context.like()
                } label: {
                    Image(systemName: "hand.thumbsup.circle")
                        .resizable()
                        .tint(.green)
                        .frame(width: 64.0, height: 64.0)
                }
                Spacer()
            }
        } onAction: { item, action in
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
