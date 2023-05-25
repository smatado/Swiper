import SwiftUI

/// Enum representing the user action on a card in the Swiper view.
public enum SwipeAction {
    case none, dislike, like
}

/// Context could be passed to `View` builder closures to call like, dislike or rollback actions from custom defined buttons.
public struct SwiperContext {
    
    /// Performs a rollback animation to the previous card according to the `SwipeAction` passed in parameter.
    public let rollback: (SwipeAction) -> Void
    
    /// Performs a like animation and show the next card. `onSwipeAction` callback will be called then.
    public let like: () -> Void
    
    /// Performs a dislike animation and show the next card. `onSwipeAction` callback will be called then.
    public let dislike: () -> Void
}

/**
 A view that displays a deck of swipeable cards.

 Use a `Swiper` to present a collection of data items as swipeable cards, with each card being rendered using a custom `View` builder closure.
 
 `buttons` closure could be used to add bottom action buttons. The `Context` could be used to trigger actions (like, dislike or rollback).
 
 When the user swipes a card, the `onAction` closure is called with the swiped data item and the direction of the swipe.
 
 The component also supports configuring swipe gesture threshold, animation durations, and rotation ratios.
 
 Example usage:
 ```
 Swiper(data: $cards) { item, action, context in
    CardView(cardModel: item, userAction: action)
 } buttons: { context in
    HStack {
        Button("Rollback") { context.rollback(previousAction) }
        Button("Dislike") { context.dislike() }
        Button("Like") { context.like() }
    }
 } onAction: { item, action in
    didSwipe(item: item, action: action)
 }
 .rotationRatio(0.05)
 .swipeThreshold(50.0)
 .animationDuration(0.15)
 ```
 */

public struct Swiper<Data: Identifiable & Equatable, Content: View, Buttons: View>: View {
    
    @Binding public var data: [Data]
    public var content: (Data, SwipeAction, SwiperContext) -> Content
    public var buttons: (SwiperContext) -> Buttons
    public var onAction: (Data, SwipeAction) -> Void
    
    private let rotationRatio: Double
    private let swipeThreshold: Double
    private let animationDuration: Double

    @State private var cardIndex: Int = 0
    @State private var swipeAction: SwipeAction = .none
    @State private var topCardOffset: CGSize = .zero
    @State private var isAnimating = false
    
    public init(data: Binding<[Data]>,
                @ViewBuilder content: @escaping (Data, SwipeAction, SwiperContext) -> Content,
                @ViewBuilder buttons: @escaping (SwiperContext) -> Buttons = { _ in EmptyView() },
                onAction: @escaping (Data, SwipeAction) -> Void,
                rotationRatio: Double = 0.05,
                swipeThreshold: Double = 50.0,
                animationDuration: Double = 0.15) {
        self._data = data
        self.content = content
        self.buttons = buttons
        self.onAction = onAction
        self.rotationRatio = rotationRatio
        self.swipeThreshold = swipeThreshold
        self.animationDuration = animationDuration
    }
    
    public init(data: [Data],
                @ViewBuilder content: @escaping (Data, SwipeAction, SwiperContext) -> Content,
                @ViewBuilder buttons: @escaping (SwiperContext) -> Buttons = { _ in EmptyView() },
                onAction: @escaping (Data, SwipeAction) -> Void,
                rotationRatio: Double = 0.05,
                swipeThreshold: Double = 50.0,
                animationDuration: Double = 0.15) {
        self.init(data: .constant(data), content: content, buttons: buttons, onAction: onAction,
                  rotationRatio: rotationRatio, swipeThreshold: swipeThreshold, animationDuration: animationDuration)
    }
    
    public var body: some View {
        let context = SwiperContext(rollback: rollback, like: like, dislike: dislike)
        VStack {
            ZStack {
                ForEach(visibleItems, id: \.id) { item in
                    let isTopCard = item.id == visibleItems.last?.id
                    content(item, isTopCard ? swipeAction : .none, context)
                        .offset(isTopCard ? topCardOffset : .zero)
                        .rotationEffect(isTopCard ? .degrees(topCardOffset.width * rotationRatio) : .zero)
                }
            }
            .gesture(gesture())
            .allowsHitTesting(!isAnimating) // Avoid interaction when animation is not completed
            .onChange(of: data) { _ in
                cardIndex = 0
            }
            buttons(context)
        }
    }
    
    public func rotationRatio(_ rotationRatio: Double) -> Self {
        Self.init(data: _data, content: content, buttons: buttons, onAction: onAction,
                  rotationRatio: rotationRatio, swipeThreshold: swipeThreshold, animationDuration: animationDuration)
    }
    
    public func swipeThreshold(_ swipeThreshold: Double) -> Self {
        Self.init(data: _data, content: content, buttons: buttons, onAction: onAction,
                  rotationRatio: rotationRatio, swipeThreshold: swipeThreshold, animationDuration: animationDuration)
    }
    
    public func animationDuration(_ animationDuration: Double) -> Self {
        Self.init(data: _data, content: content, buttons: buttons, onAction: onAction,
                  rotationRatio: rotationRatio, swipeThreshold: swipeThreshold, animationDuration: animationDuration)
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
        swipeAction = swipeAction(from: value.translation)
    }
    
    private func onDragEnded(value: DragGesture.Value) {
        isAnimating = true
        endDragging()
    }
    
    private func like() {
        animateAction(action: .like)
    }

    private func dislike() {
        animateAction(action: .dislike)
    }

    private func rollback(action: SwipeAction) {
        guard cardIndex > 0 else { return }
        
        topCardOffset = cardFinalPosition(swipeAction: action, topCardOffset: offset(for: action))
        cardIndex -= 1
        
        withAnimation(.easeOut(duration: animationDuration)) {
            topCardOffset = .zero
        }
        
        // Called after the animation has been completed
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            swipeAction = .none
        }
    }
    
    private func animateAction(action: SwipeAction) {
        guard !isAnimating else { return }
        
        isAnimating = true
        swipeAction = action
                
        withAnimation(.easeIn(duration: animationDuration)) {
            topCardOffset = offset(for: action)
        }
        
        // Called after the animation has been completed
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            endDragging()
        }
    }
    
    private func offset(for action: SwipeAction) -> CGSize {
        switch action {
        case .none:
            return .zero
        case .dislike:
            return .init(width: -swipeThreshold, height: 0.0)
        case .like:
            return .init(width: swipeThreshold, height: 0.0)
        }
    }
    
    private func endDragging() {
        onAction(data[cardIndex], swipeAction)

        withAnimation(.spring(dampingFraction: 0.5, blendDuration: animationDuration)) {
            topCardOffset = cardFinalPosition(swipeAction: swipeAction, topCardOffset: topCardOffset)
        }
        
        // Called after the animation has been completed
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            isAnimating = false
            onAnimationCompleted()
        }
    }
    
    private func swipeAction(from translation: CGSize) -> SwipeAction {
        if translation.width > swipeThreshold {
            return .like
        } else if translation.width < -swipeThreshold {
            return .dislike
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
