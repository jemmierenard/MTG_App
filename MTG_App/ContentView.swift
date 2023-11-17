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
        ScrollView {
            VStack(spacing: 10) {
                CardImageView(imageURL: card.image_uris?.large)
                    .padding()
                
                Text(card.name)
                    .font(.title)
                    
                if let collectorNumber = card.collector_number {
                    Text("Collector Number: \(collectorNumber)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Type: \(card.type_line)")
                    Text("Oracle Text: \(card.oracle_text)")
                }
                .padding()
                
                // Display legalities information
                if let legalities = card.legalities, !legalities.isEmpty {
                    Section(header: Text("Legalities")) {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 5), GridItem(.flexible(), spacing: 5)], spacing: 10) {
                            ForEach(legalities.sorted(by: { $0.key < $1.key }), id: \.key) { legality in
                                HStack {
                                    Spacer()
                                    Text(legality.value)
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(getBackgroundStyle(for: legality.value).0)
                                        .cornerRadius(3)
                                        .frame(width: getBackgroundStyle(for: legality.value).1.width, height: getBackgroundStyle(for: legality.value).1.height)
                                    Spacer()
                                    
                                    Text(legality.key)
                                        .foregroundColor(.black)
                                        .frame(width: 65, alignment: .leading)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding()
            .navigationBarTitle(Text(card.name), displayMode: .inline)
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

