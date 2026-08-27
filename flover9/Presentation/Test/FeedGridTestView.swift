//
//  FeedGridTestView.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//


import SwiftUI

struct FeedGridTestView: View {

    private let repository: FeedRepositoryProtocol

    @State private var feeds: [FeedEntity] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    init(repository: any FeedRepositoryProtocol) {
        self.repository = repository
    }

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if let errorMessage {
                    ContentUnavailableView(
                        "불러오기 실패",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: columns,
                            spacing: 2
                        ) {
                            ForEach(feeds) { feed in
                                feedCell(feed)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Feed Images Test")
        }
        .task {
            await loadFeeds()
        }
    }
}
private extension FeedGridTestView {

    @ViewBuilder
    func feedCell(_ feed: FeedEntity) -> some View {
        GeometryReader { proxy in
            AsyncImage(url: feed.thumbnailURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.gray.opacity(0.15)
                        ProgressView()
                    }

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    ZStack {
                        Color.gray.opacity(0.15)

                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }

                @unknown default:
                    EmptyView()
                }
            }
            .frame(
                width: proxy.size.width,
                height: proxy.size.width
            )
            .clipped()
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @MainActor
    func loadFeeds() async {
//        isLoading = true
//        defer { isLoading = false }
//
//        do {
//            feeds = try await repository.fetchFeeds(limit: 20)
//        } catch {
//            errorMessage = error.localizedDescription
//        }
    }
}
