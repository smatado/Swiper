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
    @State var lastAction: SwipeAction = .none

    var body: some View {
        Swiper(data: $items) { item, action, context in
            CardView(cardModel: item, userAction: action, context: context)
        } buttons: { context in
            HStack {
                Spacer()
                Button {
                    context.rollback(lastAction)
                    self.lastAction = .none
                } label: {
                    Image(systemName: "arrow.uturn.backward.circle")
                        .resizable()
                        .tint(.blue)
                        .frame(width: 64.0, height: 64.0)
                }
                .disabled(lastAction == .none)
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
            lastAction = action
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
