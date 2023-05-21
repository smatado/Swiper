import SwiftUI

/// Enum representing the user action on a card in the Swiper view.
public enum SwipeAction {
    case none, left, right
}

/**
 A view that displays a deck of swipeable cards.
 
 Use a `Swiper` to present a collection of data items as swipeable cards, with each card being rendered using a custom `View` builder closure. When the user swipes a card, the `onSwipe` closure is called with the swiped data item and the direction of the swipe. The deck also supports configuring swipe gesture thresholds, animation durations, and rotation ratios.
 
 Example usage:
 ```
 Swiper(data: $cards) { item, action in
     CardView(cardModel: item, userAction: action)
 } onSwipe: { item, action in
     didSwipe(item: item, action: action)
 }
 .rotationRatio(50.0)
 .swipeThreshold(50.0)
 .animationDuration(0.15)
 ```
 
 - Parameters:
    - data: A binding to an array of data items that will be presented as cards.
    - content: A closure that returns a custom view builder `View` for a given data item and swipe action.
    - onSwipe: A closure that is called when the user swipes a card, with the swiped data item and the swipe action.
    - rotationRatio: Rotation ratio in degrees per points of the horizontal translation, default is 0.05.
    - swipeThreshold: The minimum horizontal translation threshold required to register a swipe action, default is 50.0.
    - animationDuration: The duration of the swipe animation when user releases the card, default is 0.15 seconds.
 */

public struct Swiper<Data: Identifiable & Equatable, Content: View>: View {
    
    @Binding public var data: [Data]
    public var content: (Data, SwipeAction) -> Content
    public var onSwipe: (Data, SwipeAction) -> Void
    
    private let rotationRatio: Double
    private let swipeThreshold: Double
    private let animationDuration: Double

    @State private var cardIndex: Int = 0
    @State private var swipeAction: SwipeAction = .none
    @State private var topCardOffset: CGSize = .zero
    @State private var isAnimating = false
    
    public init(data: Binding<[Data]>, @ViewBuilder content: @escaping (Data, SwipeAction) -> Content, onSwipe: @escaping (Data, SwipeAction) -> Void,
                rotationRatio: Double = 0.05, swipeThreshold: Double = 50.0, animationDuration: Double = 0.15) {
        self._data = data
        self.content = content
        self.onSwipe = onSwipe
        self.rotationRatio = rotationRatio
        self.swipeThreshold = swipeThreshold
        self.animationDuration = animationDuration
    }
    
    public func rotationRatio(_ rotationRatio: Double) -> Self {
        Self.init(data: _data, content: content, onSwipe: onSwipe,
                  rotationRatio: rotationRatio, swipeThreshold: swipeThreshold, animationDuration: animationDuration)
    }
    
    public func swipeThreshold(_ swipeThreshold: Double) -> Self {
        Self.init(data: _data, content: content, onSwipe: onSwipe,
                  rotationRatio: rotationRatio, swipeThreshold: swipeThreshold, animationDuration: animationDuration)
    }
    
    public func animationDuration(_ animationDuration: Double) -> Self {
        Self.init(data: _data, content: content, onSwipe: onSwipe,
                  rotationRatio: rotationRatio, swipeThreshold: swipeThreshold, animationDuration: animationDuration)
    }
    
    public var body: some View {
        ZStack {
            ForEach(visibleItems, id: \.id) { item in
                let isTopCard = item.id == visibleItems.last?.id
                content(item, isTopCard ? swipeAction : .none)
                    .offset(isTopCard ? topCardOffset : .zero)
                    .rotationEffect(isTopCard ? .degrees(topCardOffset.width * rotationRatio) : .zero)
            }
        }
        .gesture(gesture())
        .allowsHitTesting(!isAnimating) // Avoid interaction when animation is not completed
        .onChange(of: data) { _ in
            cardIndex = 0
        }
    }
    
    private var visibleItems: [Data] {
        guard cardIndex < data.count else { return [] }
        let lastIndex = data.count - 1
        let lastVisibleIndex = min(lastIndex, cardIndex + 1)
        return data[cardIndex...lastVisibleIndex].reversed()
    }
    
    private func gesture() -> some Gesture {
        DragGesture()
            .onChanged(onDragChanged)
            .onEnded(onDragEnded)
    }
    
    private func onDragChanged(value: DragGesture.Value) {
        topCardOffset = value.translation
        swipeAction = swipeAction(translation: value.translation)
    }
    
    private func onDragEnded(value: DragGesture.Value) {
        onSwipe(data[cardIndex], swipeAction)

        isAnimating = true

        withAnimation(.spring(dampingFraction: 0.5, blendDuration: animationDuration)) {
            topCardOffset = cardFinalPosition(swipeAction: swipeAction, topCardOffset: topCardOffset)
        }
        
        // Called after the animation has been completed
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            isAnimating = false
            onAnimationCompleted()
        }
    }
    
    private func swipeAction(translation: CGSize) -> SwipeAction {
        if translation.width > swipeThreshold {
            return .right
        } else if translation.width < -swipeThreshold {
            return .left
        } else {
            return .none
        }
    }
    
    private func cardFinalPosition(swipeAction: SwipeAction, topCardOffset: CGSize) -> CGSize {
        guard swipeAction != .none else { return .zero }
        let angle = atan2(topCardOffset.height, topCardOffset.width)
        let x = cos(angle) * UIScreen.main.bounds.width
        let y = sin(angle) * UIScreen.main.bounds.height
        return .init(width: x, height: y)
    }
    
    private func onAnimationCompleted() {
        guard swipeAction != .none else { return }
        cardIndex += 1
        topCardOffset = .zero
        swipeAction = .none
    }
}
