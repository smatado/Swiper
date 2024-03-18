//
//  ButtonBar.swift
//  LoremPicsum
//
//  Created by Silbino Gonçalves Matado on 2024-05-20.
//

import SwiftUI
import Swiper

struct ButtonBar: View {
    
    @Binding var lastSwipedDirection: Edge?
    @Binding var swipeStackProxy: SwipeStackProxy
    
    private let buttonSize: CGSize = .init(width: 64.0, height: 64.0)
    
    var body: some View {
        HStack {
            Spacer()

            actionButton(imageSystemName: "arrow.uturn.backward.circle", tint: .blue) {
                guard let lastSwipedDirection = lastSwipedDirection else {
                    return
                }
                swipeStackProxy.rollback(lastSwipedDirection)
            }
            .disabled(lastSwipedDirection == nil)

            Spacer()

            actionButton(imageSystemName: "hand.thumbsup.circle", tint: .green) {
                swipeStackProxy.swipe(.trailing)
                lastSwipedDirection = .trailing
            }
            
            Spacer()

            actionButton(imageSystemName: "hand.thumbsdown.circle", tint: .red) {
                swipeStackProxy.swipe(.leading)
                lastSwipedDirection = .leading
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
            .cornerRadius(16.0)
    }
    
    @ViewBuilder
    private func actionButton(imageSystemName: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: imageSystemName)
                .resizable()
                .tint(tint)
                .frame(width: buttonSize.width, height: buttonSize.height)
        }
    }
}
