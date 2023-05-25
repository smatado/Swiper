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
    let userAction: SwipeAction
    let context: SwiperContext

    var body: some View {
        GeometryReader { reader in
            ZStack {
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
        Rectangle()
            .fill(userAction.overlayColor.opacity(0.25))
        if let overlayImageName = userAction.overlayImageName {
            Image(systemName: overlayImageName)
                .font(.system(size: 200.0))
                .foregroundColor(userAction.overlayColor)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    
    static var items: [CardModel] = (10...1000).map { CardModel(id: $0) }

    static var previews: some View {
        Swiper(data: items) { item, action, context in
            CardView(cardModel: item, userAction: action, context: context)
        } onAction: { _,_  in
          print("onAction")
        }
    }
}

fileprivate extension SwipeAction {
    var overlayImageName: String? {
        switch self {
        case .none:
            return nil
        case .dislike:
            return "hand.thumbsdown.circle"
        case .like:
            return "hand.thumbsup.circle"
        }
    }
    
    var overlayColor: Color {
        switch self {
        case .none:
            return .clear
        case .dislike:
            return .red
        case .like:
            return .green
        }
    }
}
