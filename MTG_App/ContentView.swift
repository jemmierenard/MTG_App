import SwiftUI

struct CardImageView: View {
    var imageURL: String?
    
    var body: some View {
        if let imageURL = imageURL {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                case .empty:
                    ProgressView()
                @unknown default:
                    ProgressView()
                }
            }
        } else {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.gray)
        }
    }
}

struct MTGCardView: View {
    @State private var isShowingLargeImage = false
    @State private var selectedLegalityIndex = 0 // Track the selected legality index

    
    var card: MTGCard

    private func getBackgroundStyle(for legality: String) -> (Color, CGSize) {
        switch legality.lowercased() {
        case "legal":
            return (.green, CGSize(width: 100, height: 40))
        case "not legal":
            return (.gray, CGSize(width: 100, height: 40))
        case "restricted":
            return (.red, CGSize(width: 100, height: 40))
        case "banned":
            return (.red, CGSize(width: 100, height: 40))
        default:
            return (.gray, CGSize(width: 100, height: 40))
        }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 10) {
                    CardImageView(imageURL: card.image_uris?.art_crop)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            // Show the large image when tapped
                            isShowingLargeImage = true
                        }


                    VStack(alignment: .leading, spacing: 10) {
                        Text(card.name)
                            .font(.title)
                        if let collectorNumber = card.collector_number {
                            Text("Collector Number: \(collectorNumber)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)
                        }
                        Text(card.type_line)
                        Text(card.oracle_text)
                    }
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1) // Adjust color and line width as needed
                            .background(Color.clear) // Transparent background
                    )


                    // Display legalities information
                    if let legalities = card.legalities, !legalities.isEmpty {
                        Section(header: Text("Legalities")) {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 5), GridItem(.flexible(), spacing: 5)], spacing: 10) {
                                ForEach(legalities.sorted(by: { $0.key < $1.key }), id: \.key) { legality in
                                    HStack {
                                        // Overlay Rectangle
                                        Rectangle()
                                            .foregroundColor(getBackgroundStyle(for: legality.value).0)
                                            .cornerRadius(3)
                                            .frame(width: getBackgroundStyle(for: legality.value).1.width, height: getBackgroundStyle(for: legality.value).1.height)
                                            .zIndex(1) // Ensure the rectangle is on top
                                            .overlay {
                                                // Text for legality value
                                                Text(legality.value)
                                                    .foregroundColor(.white)
                                                    .padding(6)
                                                    .cornerRadius(3)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        // Text for legality key
                                        Text(legality.key)
                                            .foregroundColor(.black)
                                            .frame(width: 65, alignment: .leading)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    
                    }
                }
                .navigationBarTitle(Text(card.name), displayMode: .inline)
            }

            // Large Image Popup
            if isShowingLargeImage {
                Color.black.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // Dismiss the large image popup when tapped
                        isShowingLargeImage = false
                    }

                if let largeImageURL = card.image_uris?.large {
                    // Display a larger image as a popup overlay
                    AsyncImage(url: URL(string: largeImageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .cornerRadius(16)
                                .padding(20)
                        case .failure:
                            // Handle failure, you can display an error image or message
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .cornerRadius(16)
                                .padding(20)
                        case .empty:
                            // Placeholder or loading indicator
                            ProgressView()
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .cornerRadius(16)
                                .padding(20)
                        @unknown default:
                            // Handle unknown state
                            ProgressView()
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .cornerRadius(16)
                                .padding(20)
                        }
                    }
                }
            }
        }
    }
}

    
    struct SearchBar: View {
        @Binding var searchText: String
        
        var body: some View {
            HStack {
                TextField("Search...", text: $searchText)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(8)
                }
                .padding(.trailing, 10)
                .opacity(searchText.isEmpty ? 0 : 1)
                .animation(.default)
            }
        }
    }
    
    struct ContentView: View {
        @State private var mtgCards: [MTGCard] = []
        @State private var searchText: String = ""
        @State private var sortCriteria: SortCriteria = .name
        
        enum SortCriteria: String, CaseIterable {
            case name = "Name"
            case collectorNumber = "Collector Number"
        }
        
        
        var sortedCards: [MTGCard] {
            switch sortCriteria {
            case .name:
                return mtgCards.sorted { $0.name < $1.name }
            case .collectorNumber:
                return mtgCards.sorted { ($0.collector_number ?? "") < ($1.collector_number ?? "") }
            }
        }
        
        
        var filteredCards: [MTGCard] {
            if searchText.isEmpty {
                return sortedCards
            } else {
                return sortedCards.filter { card in
                    let nameMatch = card.name.lowercased().contains(searchText.lowercased())
                    let collectorNumberMatch = card.collector_number?.lowercased().contains(searchText.lowercased()) ?? false
                    return nameMatch || collectorNumberMatch
                }
            }
        }
        
        var body: some View {
            TabView{
                
                
                NavigationView {
                    VStack {
                        SearchBar(searchText: $searchText)
                            .padding()
                        
                        Picker("Sort By", selection: $sortCriteria) {
                            ForEach(SortCriteria.allCases, id: \.self) { criteria in
                                Text(criteria.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 16) {
                                ForEach(filteredCards) { card in
                                    NavigationLink(destination: MTGCardView(card: card)) {
                                        VStack {
                                            CardImageView(imageURL: card.image_uris?.large)
                                                .frame(width: 80, height: 120)
                                            
                                            Text(card.name)
                                                .font(.caption)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 8)
                                        }
                                        .padding(12)
                                        .background(Color.secondary.opacity(0.2))
                                        .cornerRadius(10)
                                    }
                                }
                                
                            }
                            .padding()
                        }
                    }
                    .onAppear {
                        // Load data from JSON file
                        if let data = loadJSON() {
                            do {
                                let decoder = JSONDecoder()
                                let cards = try decoder.decode(MTGCardList.self, from: data)
                                mtgCards = cards.data
                            } catch {
                                print("Error decoding JSON: \(error)")
                            }
                        }
                    }
                    
                    .navigationBarTitle("MTG Cards")
                }
                .tabItem {
                                Image(systemName: "house")
                                Text("Home")
                            }

                            // Search Tab
                            Text("Search")
                                .tabItem {
                                    Image(systemName: "magnifyingglass")
                                    Text("Search")
                                }

                            // Collection Tab
                            Text("Collection")
                                .tabItem {
                                    Image(systemName: "folder")
                                    Text("Collection")
                                }

                            // Decks Tab
                            Text("Decks")
                                .tabItem {
                                    Image(systemName: "square.grid.2x2")
                                    Text("Decks")
                                }

                            // Scan Tab
                            Text("Scan")
                                .tabItem {
                                    Image(systemName: "qrcode.viewfinder")
                                    Text("Scan")
                                }
            }
        }
        
        
        func loadJSON() -> Data? {
            if let path = Bundle.main.path(forResource: "WOT-Scryfall", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    return data
                } catch {
                    print("Error loading JSON: \(error)")
                }
            }
            return nil
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

