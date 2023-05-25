# Swiper 🎴

![Swift version](https://img.shields.io/badge/Swift-5.4-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20iPadOS%2014.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A SwiftUI generic swipeable card stack as in dating apps.

## Features

- Generic: The container can be used with any View and Data
- Lazy: Only renders the visible cards for better performance and less memory usage
- Customization: Allows card customization with user action (ex: like/dislike overlay) 
- Rollback support: Allows the user to rollback to the previous card.
- Action buttons: You can provide custom buttons to call like/dislike/rollback actions. These buttons could be integrated to your cards or at the bottom of the cards.

## Installation

### Swift Package Manager

1. Go to **File** -> **Add Packages...**

2. Type `git@github.com:Nifty-Code/Swiper.git` in the search bar.

3. Click on **Add Package**.

That's it! The Swift package will be added to your project.

## Usage

### Basic Usage

```swift
import SwiftUI
import Swiper

struct ContentView: View {
    @State var cards: [Card] = // your card data
    
    var body: some View {
        Swiper(data: $cards) { item, action, _ in
            CardView(cardModel: item, userAction: action) // <--- Your custom View here
        } onAction: { item, action in
            didSwipe(item: item, action: action) // <--- Handle Swipe action here
        }
        .rotationRatio(0.05) // <--- Rotation ratio in degrees per points
        .swipeThreshold(50.0) // <--- The minimum horizontal translation
        .animationDuration(0.15) // <--- Duration of the swipe animation when user releases the card
        .padding()
    }
}
```

### Custom action buttons

```swift
import SwiftUI
import Swiper

struct ContentView: View {
    @State var cards: [Card] = // your card data
    
    var body: some View {
        Swiper(data: $cards) { item, action, context in
            CardView(cardModel: item, userAction: action, context: context) // <--- Context could be passed here if action buttons are integrated to the card
        } buttons: { context in
            HStack {
                RollbackButton { context.rollback(previousAction) }  // <--- Call the rollback action here. You must manage the previous actions
                DislikeButton { context.dislike() }  // <--- Call the dislike action here
                LikeButton { context.like() }  // <--- Call the like action here
            }
        } onAction: { item, action in
            didSwipe(item: item, action: action)
        }
        .padding()
    }
}
```

## Contributing

Contributions and suggestions are welcome! 
To contribute to this library, please fork this repository or submit a pull request with your changes.


## License

This library is released under the MIT license. See [LICENSE](LICENSE) for more information.
