import SwiftUI

/// A proxy to control the swipe actions programmatically.
public struct SwipeStackProxy {
    
    /// A closure that triggers a swipe action in the specified direction.
    public var swipe: ((Edge) -> Void)! = nil
    
    /// A closure that triggers a rollback action in the specified direction.
    public var rollback: ((Edge) -> Void)! = nil
    
    /// Creates a new instance of `SwipeStackProxy`.
    public init() {}
}

/// A configuration struct for customizing the behavior and appearance of the `SwipeStack`.
public struct SwipeStackConfiguration {
    
    /// The ratio of rotation applied to the card during a swipe.
    var rotationRatio: Double
    
    /// The distance for triggering a swipe action.
    var swipeThreshold: Double
    
    /// The maximum scale applied to the top card during a swipe.
    var maxCardScale: Double
    
    /// The factor by which the scale effect is adjusted during a swipe.
    var scaleEffectAdjustmentFactor: Double
    
    /// The factor by which the shadow radius is scaled during a swipe.
    var shadowRadiusScalingFactor: Double
    
    /// Creates a new instance of `SwipeStackConfiguration` with default or custom values.
    /// - Parameters:
    ///   - rotationRatio: The ratio of rotation applied to the card during a swipe. Default is `0.05`.
    ///   - swipeThreshold: The distance for triggering a swipe action. Default is `50.0`.
    ///   - maxCardScale: The maximum scale applied to the top card during a swipe. Default is `1.2`.
    ///   - scaleEffectAdjustmentFactor: The factor by which the scale effect is adjusted during a swipe. Default is `0.0025`.
    ///   - shadowRadiusScalingFactor: The factor by which the shadow radius is scaled during a swipe. Default is `0.1`.
    public init(rotationRatio: Double = 0.05,
                swipeThreshold: Double = 50.0,
                maxCardScale: Double = 1.2,
                scaleEffectAdjustmentFactor: Double = 0.0025,
                shadowRadiusScalingFactor: Double = 0.1) {
        self.rotationRatio = rotationRatio
        self.swipeThreshold = swipeThreshold
        self.maxCardScale = maxCardScale
        self.scaleEffectAdjustmentFactor = scaleEffectAdjustmentFactor
        self.shadowRadiusScalingFactor = shadowRadiusScalingFactor
    }
}


public struct SwipeStack<Data: Identifiable & Equatable, Content: View>: View {
    
    @Binding public var data: [Data]
    @Binding public var proxy: SwipeStackProxy
    
    public var content: (Data, Edge?) -> Content
    public var onSwipe: (Edge) -> Void
    public var onRollback: ((Edge) -> Void)?

    @State private var swipeDirection: Edge? = .none
    @State private var cardIndex: Int = 0
    @State private var topCardOffset: CGSize = .zero
    @State private var isAnimating = false
    @State private var scaleEffect: CGFloat = 1.0
    @State private var shadowRadius: CGFloat = 0.0
    
    private let configuration: SwipeStackConfiguration
    private let animationDuration: Double = 0.15
    private let defaultCardScale: Double = 1.0
    
    /// A view that displays a stack of swipeable cards.
    /// - Parameters:
    ///   - data: A binding to the array of data items to be displayed as cards.
    ///   - proxy: A binding to a `SwipeStackProxy` to control swipe actions programmatically. Default is a constant proxy.
    ///   - configuration: The configuration for customizing the behavior and appearance of the `SwipeStack`. Default is `SwipeStackConfiguration()`.
    ///   - content: A closure that returns the view for each card.
    ///   - onSwipe: A closure that is called when a card is swiped.
    ///   - onRollback: A closure that is called when a swipe is rolled back.
    public init(data: Binding<[Data]>,
                proxy: Binding<SwipeStackProxy> = .constant(SwipeStackProxy()),
                configuration: SwipeStackConfiguration = SwipeStackConfiguration(),
                @ViewBuilder content: @escaping (Data, Edge?) -> Content,
                onSwipe: @escaping (Edge) -> Void,
                onRollback: ((Edge) -> Void)? = nil) {
        self._data = data
        self._proxy = proxy
        self.configuration = configuration
        self.content = content
        self.onSwipe = onSwipe
        self.onRollback = onRollback
    }
    
    public var body: some View {
        ZStack {
            ForEach(visibleItems, id: \.id) { item in
                let isTopCard = item.id == visibleItems.last?.id
                content(item, isTopCard ? swipeDirection : .none)
                    .offset(isTopCard ? topCardOffset : .zero)
                    .rotationEffect(isTopCard ? .degrees(topCardOffset.width * configuration.rotationRatio) : .zero)
                    .scaleEffect(isTopCard ? scaleEffect : defaultCardScale)
                    .shadow(color: .black, radius: isTopCard ? shadowRadius : 0.0)
            }
        }
        .gesture(gesture())
        .allowsHitTesting(!isAnimating) // Avoid interaction when animation is not completed
        .onChange(of: data) {
            cardIndex = 0
        }
        .onAppear {
            proxy.rollback = rollback
            proxy.swipe = swipe
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
        swipeDirection = swipeDirection(from: value.translation)
        let maxAbsoluteTranslation = max(abs(value.translation.width), abs(value.translation.height))
        scaleEffect = min(configuration.maxCardScale, 1.0 + maxAbsoluteTranslation * configuration.scaleEffectAdjustmentFactor)
        shadowRadius = maxAbsoluteTranslation * configuration.shadowRadiusScalingFactor
    }
    
    private func onDragEnded(value: DragGesture.Value) {
        isAnimating = true
        endDragging()
    }

    private func rollback(swipeDirection: Edge) {
        guard swipeDirection == .leading || swipeDirection == .trailing else {
            print("⚠️ SwipeStack: Only .leading or .trailing directions are valid.")
            return
        }
        
        guard cardIndex > 0 else { return }
        
        onRollback?(swipeDirection)
                
        topCardOffset = cardFinalPosition(swipeDirection: swipeDirection, topCardOffset: offset(for: swipeDirection))
        cardIndex -= 1
        
        withAnimation(.easeOut(duration: animationDuration)) {
            topCardOffset = .zero
        } completion: {
            self.swipeDirection = .none
        }
    }
    
    private func swipe(swipeDirection: Edge) {
        guard swipeDirection == .leading || swipeDirection == .trailing else {
            print("⚠️ SwipeStack: Only .leading or .trailing directions are valid.")
            return
        }

        guard !isAnimating else { return }
        
        isAnimating = true
        self.swipeDirection = swipeDirection
                
        withAnimation(.easeIn(duration: animationDuration)) {
            topCardOffset = offset(for: swipeDirection)
        } completion: {
            endDragging()
        }
    }
    
    private func offset(for swipeDirection: Edge?) -> CGSize {
        switch swipeDirection {
        case .some(.trailing):
            return .init(width: configuration.swipeThreshold, height: 0.0)
        case .some(.leading):
            return .init(width: -configuration.swipeThreshold, height: 0.0)
        case .none, .some(.top), .some(.bottom):
            return .zero
        }
    }
    
    private func endDragging() {
        switch swipeDirection {
        case .none:
            break
        case .some(let swipeDirection):
            onSwipe(swipeDirection)
        }
        
        withAnimation(.easeOut(duration: animationDuration)) {
            topCardOffset = cardFinalPosition(swipeDirection: swipeDirection, topCardOffset: topCardOffset)
            scaleEffect = defaultCardScale
        } completion: {
            isAnimating = false
            onAnimationCompleted()
            shadowRadius = 0.0
        }
    }
    
    private func swipeDirection(from translation: CGSize) -> Edge? {
        if translation.width > configuration.swipeThreshold {
            return .trailing
        } else if translation.width < -configuration.swipeThreshold {
            return .leading
        } else {
            return .none
        }
    }
    
    private func cardFinalPosition(swipeDirection: Edge?, topCardOffset: CGSize) -> CGSize {
        guard swipeDirection != .none else { return .zero }
        let angle = atan2(topCardOffset.height, topCardOffset.width)
        let x = cos(angle) * UIScreen.main.bounds.width
        let y = sin(angle) * UIScreen.main.bounds.height
        return .init(width: x, height: y)
    }
    
    private func onAnimationCompleted() {
        guard swipeDirection != .none else { return }
        cardIndex += 1
        topCardOffset = .zero
        swipeDirection = .none
    }
}
