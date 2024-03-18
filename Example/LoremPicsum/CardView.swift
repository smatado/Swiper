//
//  CardView.swift
//  Swipe
//
//  Created by Silbino Gonçalves Matado on 2023-04-22.
//

import SwiftUI
import Swiper

struct CardView: View {
    
    let cardModel: CardModel
    let swipeDirection: Edge?
    
    @Binding var showButtonBarInCard: Bool
    @Binding var lastSwipedDirection: Edge?
    @Binding var swipeStackProxy: SwipeStackProxy

    var body: some View {
        GeometryReader { reader in
            ZStack(alignment: .bottom) {
                let url = URL(string: "https://picsum.photos/id/\(cardModel.id)/\(Int(reader.size.width))/\(Int(reader.size.height))")
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: reader.size.width, height: reader.size.height)
                        .clipped()
                } placeholder: {
                    imagePlaceholder()
                }
                
                numberLabel()
                    .frame(width: reader.size.width,
                           height: reader.size.height,
                           alignment: .topLeading)
                
                actionOverlay()
                
                if showButtonBarInCard {
                    ButtonBar(lastSwipedDirection: $lastSwipedDirection, swipeStackProxy: $swipeStackProxy)
                        .padding()
                        .zIndex(0.0)
                }
            }
        }
        .cornerRadius(16.0)
    }
    
    @ViewBuilder private func imagePlaceholder() -> some View {
        ZStack {
            Rectangle()
                .fill(Color.gray)
            ProgressView()
                .controlSize(.large)
        }
    }
    
    @ViewBuilder private func numberLabel() -> some View {
        Text("#\(cardModel.id)").fontWeight(.bold)
            .padding()
            .background(
                Rectangle()
                    .fill(.white)
                    .opacity(0.8)
                    .cornerRadius(16.0)
            )
            .padding()
    }
    
    @ViewBuilder private func actionOverlay() -> some View {
        ZStack {
            Rectangle()
                .fill(swipeDirection.overlayColor.opacity(0.25))
            Image(systemName: swipeDirection.overlayImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(swipeDirection.overlayColor)
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .top)
                .padding()

        }
        .opacity(swipeDirection.overlayOpacity)
        .animation(.default, value: swipeDirection.overlayOpacity)
    }
}

fileprivate extension Optional where Wrapped == Edge {
    var overlayImageName: String {
        switch self {
        case .trailing:
            return "hand.thumbsup.circle"
        case .leading, .none, .top, .bottom:
            return "hand.thumbsdown.circle"
        }
    }
    
    var overlayColor: Color {
        switch self {
        case .leading:
            return .red
        case .trailing:
            return .green
        case .none, .top, .bottom:
            return .clear
        }
    }
    
    var overlayOpacity: CGFloat {
        switch self {
        case .none:
            return 0.0
        default:
            return 1.0
        }
    }
}
