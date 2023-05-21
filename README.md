# Swiper 🃏

![Swift version](https://img.shields.io/badge/Swift-5.4-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20iPadOS%2014.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A SwiftUI generic swipeable card stack as in dating apps.

## Features

- Generic: The container can be used with any View and Data
- Lazy: Only renders the visible cards for better performance and less memory usage
- Customization: Allows card customization with user action (ex: like/dislike overlay) 

## Installation

### Swift Package Manager

TODO

## Usage

### Basic Usage

```swift
import SwiftUI
import CardDeck

struct ContentView: View {
    @State var cards: [Card] = // your card data
    
    var body: some View {
        Swiper(data: $cards) { item, action in // <--- Pass a binding to your data here
            CardView(cardModel: item, userAction: action) // <--- Your custom View here, pass the action for customization if needed
        } onSwipe: { item, action in
            didSwipe(item: item, action: action) // <--- Handle Swipe action here
        }
        .rotationRatio(50.0) // <--- Rotation ratio in degrees per points of the horizontal translation
        .swipeThreshold(50.0) // <--- The minimum horizontal translation threshold required to register a swipe action
        .animationDuration(0.15) // <--- The duration of the swipe animation when user releases the card
        .padding([.leading, .trailing])
    }
}
```

## Contributing

Contributions and suggestions are welcome! 
To contribute to this library, please fork this repository or submit a pull request with your changes.


## License

This library is released under the MIT license. See [LICENSE](LICENSE) for more information.
