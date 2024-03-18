# Swiper 🎴

![Swift version](https://img.shields.io/badge/Swift-5.4-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20iPadOS%2014.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A SwiftUI generic swipeable card stack as in dating apps.

## Features

- **Generic**: The container can be used with any View and Data
- **Lazy**: Only renders the visible cards for better performance and less memory usage
- **Customization**: Allows card customization with user action (ex: like/dislike overlay) 
- **Rollback support**: Allows the user to rollback to the previous card.
- **Action buttons**: You can provide custom buttons to call like/dislike/rollback actions. These buttons could be integrated to your cards or at the bottom of the cards.

## Installation

### Swift Package Manager

1. Go to **File** -> **Add Packages...**

2. Type `git@github.com:smatado/Swiper.git` in the search bar.

3. Click on **Add Package**.

That's it! The Swift package will be added to your project.

## Usage

### Basic Usage

```swift
struct ContentView: View {
    
    @State var items: [Item] = ...

    var body: some View {
        SwipeStack(data: $items) { item, swipeDirection in
            // Provide your custom card here. You can pass the current swipe direction for overlay customization
            YourCard()
        } onSwipe: { swipeDirection in
            // Handle swipe here, swipe direction could be .leading, or .trailing
        }
    }
}
```

### Custom action buttons

```swift
struct ContentView: View {
    
    @State var items: [Item] = ...
    
    // Create a SwipeStackProxy to control swipe actions programmatically.
    @State private var swipeStackProxy = SwipeStackProxy() 

    var body: some View {
        VStack {
            SwipeStack(data: $items, proxy: $swipeStackProxy) { item, swipeDirection in
                // Provide your custom card here. You can pass the current swipe direction for overlay customization
                YourCard()
            } onSwipe: { swipeDirection in
                // Handle swipe here, swipe direction could be .leading, or .trailing
            } onRollback: { rollbackDirection in
                // Handle rollback here, rollback direction could be .leading, or .trailing
            }
            .zIndex(1) // Make sure the card will be above the buttons
            
            // Create your own buttons to trigger swipe left, swipe right and rollback here.
            HStack {
                Button(action: {
                    // Trigger actions from the Swipe Stack Proxy
                    swipeStackProxy.swipe(.leading)
                }) {
                    Text("Like")
                }
                
                /* add your swipe right and rollback button here... */
            }
        }
    }
}
```

### Customizing the behavior and appearance 

```swift
struct ContentView: View {
    
    @State var items: [CardModel] = (10...1000).map { CardModel(id: $0) }
    @State private var swipeStackProxy = SwipeStackProxy()

    var body: some View {
        SwipeStack(data: $items,
                   configuration: SwipeStackConfiguration(
                    rotationRatio: 0.05, // The ratio of rotation applied to the card during a swipe.
                    swipeThreshold: 50.0, // The distance for triggering a swipe action.
                    maxCardScale: 1.2, // The maximum scale applied to the top card during a swipe.
                    scaleEffectAdjustmentFactor: 0.0025, // The factor by which the scale effect is adjusted during a swipe.
                    shadowRadiusScalingFactor: 0.1 // The factor by which the shadow radius is scaled during a swipe.
                   )
        ) { item, swipeDirection in
            YourCard()
        } onSwipe: { swipeDirection in

        }
    }
}
```

## Contributing

Contributions and suggestions are welcome! 
To contribute to this library, please fork this repository or submit a pull request with your changes.


## License

This library is released under the MIT license. See [LICENSE](LICENSE) for more information.
