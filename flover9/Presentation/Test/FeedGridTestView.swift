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

    private var images: [FeedImageEntity] {
        feeds
            .flatMap(\.images)
            .sorted { $0.sortOrder < $1.sortOrder }
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
                            ForEach(images) { image in
                                imageCell(image)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Feed Images Test")
        }
        .task {
            do {
                feeds = try await repository.excute(limit: 20)

                for feed in feeds {
                    print(
                        "Feed:",
                        feed.id,
                        "images:",
                        feed.images.count,
                        "members:",
                        feed.members.count
                    )
                }
            } catch {
                print(error)
            }
        }
    }
}
private extension FeedGridTestView {

    @ViewBuilder
    func imageCell(_ image: FeedImageEntity) -> some View {
        GeometryReader { proxy in
            AsyncImage(url: URL(string: image.imageURL)) { phase in
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
        isLoading = true
        defer { isLoading = false }

        do {
            feeds = try await repository.excute(limit: 20)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
