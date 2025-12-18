# OutfitMatcher - AI-Powered Wardrobe Manager

An iOS application that helps you organize your wardrobe and create stylish outfits using AI-powered recommendations from Claude (Anthropic).

## 📱 Features

### Core Functionality
- **Digital Wardrobe**: Store and manage your clothing items with photos
- **AI Outfit Matching**: Get intelligent outfit suggestions based on color theory and fashion principles
- **Outfit Collections**: Save and organize your favorite outfit combinations
- **Calendar Integration**: Plan your outfits for specific dates
- **Category Organization**: Organize clothes by Hats, Shirts, Pants, Shoes, Dresses, and Accessories

### AI-Powered Matching
- Smart color coordination using complementary and analogous color schemes
- Seasonal appropriateness matching
- Material compatibility analysis
- Fashion trend awareness
- Animated carousel selection (slot-machine style!)
- Detailed explanations for each outfit recommendation

## 🛠 Technical Stack

### Technologies Used
- **Language**: Swift 5
- **UI Framework**: UIKit with Storyboards
- **Layout**: Auto Layout with Stack Views
- **Architecture**: MVC (Model-View-Controller)
- **Data Persistence**: UserDefaults for lightweight data, FileManager for images
- **Networking**: URLSession for API calls
- **AI Service**: Gemini

### Key Components
- `UITabBarController` - Multi-module navigation
- `UINavigationController` - Hierarchical navigation
- `UICollectionView` - Grid and carousel displays with custom cells
- `UITableView` - List displays
- `UIImagePickerController` - Camera and photo library access

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- Active internet connection for AI features

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/OutfitMatcher.git
cd OutfitMatcher
```

### 2. Get Claude API Key
1. Go to [Anthropic Console](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key (starts with `sk-ant-`)

### 3. Configure API Key
Open `AIService.swift` and replace the API key:
```swift
private let apiKey = "YOUR_API_KEY_HERE"
```

### 4. Build and Run
1. Open `OutfitMatcher.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press `Cmd + R` to build and run

## 📖 Usage Guide

### Adding Clothing Items
1. Navigate to the **Wardrobe** tab
2. Tap the **+** button
3. Take a photo or select from library
4. Fill in item details:
   - Name (e.g., "Blue Denim Jacket")
   - Category (Hat, Shirt, Pants, Shoes, etc.)
   - Color (e.g., "Blue", "Black", "White")
   - Season (Spring, Summer, Fall, Winter, All Seasons)
   - Material (e.g., "Denim", "Cotton", "Leather")
   - Size (e.g., "M", "L", "32")
5. Tap **Save**

### Getting AI Outfit Recommendations
1. Navigate to the **AI Matching** tab
2. You'll see four horizontal carousels:
   - Hats (optional)
   - Shirts
   - Pants
   - Shoes
3. Tap **Match Outfit** button
4. Watch the carousels spin! 🎰
5. Carousels will land on AI-selected items
6. Read the AI's explanation of why the outfit works
7. If you love it, tap **Save Outfit** to add it to your collection

### Saving and Managing Outfits
1. After AI matching, tap **Save Outfit**
2. Enter a name (e.g., "Summer Casual", "Office Look")
3. Find saved outfits in the **Outfits** tab
4. Tap any outfit to view details
5. Mark favorites by tapping the heart icon

### Calendar Planning
1. Navigate to the **Calendar** tab
2. Select a date
3. Assign an outfit for that day
4. View your planned outfits for the week/month

## 🎨 AI Matching Algorithm

The AI considers multiple factors when creating outfit recommendations:

### Color Theory
- **Complementary Colors**: Opposite on color wheel (e.g., blue + orange)
- **Analogous Colors**: Adjacent on color wheel (e.g., blue + green)
- **Neutral Combinations**: Black, white, gray, beige
- **Accent Colors**: Pop of color for visual interest

### Seasonal Matching
- **Winter**: Warm materials, darker colors, layered looks
- **Summer**: Light materials, bright colors, breathable fabrics
- **Spring/Fall**: Transitional pieces, medium-weight fabrics
- **All Seasons**: Versatile items that work year-round

### Material Compatibility
- Cotton + Denim = Casual comfort
- Wool + Leather = Sophisticated structure
- Silk + Cotton = Elegant mix
- Athletic fabrics = Sporty coordination

## 🔮 Future Enhancements

Potential features for future versions:
- [ ] Weather-based outfit suggestions
- [ ] Social sharing of outfits
- [ ] Outfit rating and feedback system
- [ ] Virtual try-on using AR
- [ ] Clothing care reminders
- [ ] Shopping list for missing items
- [ ] Style analytics and insights
- [ ] Multi-language support
- [ ] AI created images of person with outfits on
- [ ] iCloud sync across devices

---

**Built with ❤️ for the iOS Development Introduction course**
