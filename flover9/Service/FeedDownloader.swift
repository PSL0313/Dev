//
//  FeedDownloader.swift
//  flover9
//
//  Created by 박선린 on 10/7/26.
//
import Foundation
import Kingfisher
import BackgroundTasks
import Photos
/*
 순서
 
 외부에서 큐 할당 요청(함수): func enqueue
 
 현재 번호표 뽑기
 
 
 */

actor FeedDownloader {
    static let shared = FeedDownloader()
    static func start() {
        FeedDownloader.shared.registerBackgroundDownload()
    }
    
    private var queue: [Int:FeedImageEntity] = [:]
    private var queueAt: Int = 0
    private var waitAt = 0      // 다음 손님이 가져갈 번호표
    
    private var state: ProcessingState = .idle
    
    let identifier = "com.seonlin.flover9.download.job"
    
    private init() {}
    
    // MARK: - 백그라운드 작업을 등록
    nonisolated func registerBackgroundDownload() {
        let registered = BGTaskScheduler.shared.register(
            forTaskWithIdentifier: identifier,
            using: nil
        ) { [weak self] task in
            guard let task = task as? BGContinuedProcessingTask else {
                return
            }

            
            let processingTask = Task { [weak self ] in
                guard let self else {
                    task.setTaskCompleted(success: false)
                    return
                }
                
                let success = await self.start { total,complete in
                    // 등록 핸들러에서 작업 시작 시
                    task.progress.totalUnitCount = total
                    task.progress.completedUnitCount = complete
                    task.updateTitle(
                        "미디어 다운로드",
                        subtitle: "\(task.progress.completedUnitCount) / \(task.progress.totalUnitCount)개 저장 완료"
                    )
                }
                
                task.setTaskCompleted(success: success)
            }
            
            // 취소 요청 API
            task.expirationHandler = {
                processingTask.cancel()
            }
        }
        
        print("레지스터 등록", registered)
    }
    
    private func start(completeCounting: @escaping ((_ total: Int64 , _ completed: Int64) -> Void) ) async -> Bool {
        guard state != .running else { return true }
        state = .running
        defer { state = .idle }
        
        var success = true
        var completedDownloadCount: Int64 = 0  // 완료된 개수
        var remainingDownloadCount: Int64 = 0  // 남은 갯수
        while let item = queue.removeValue(forKey: queueAt + 1) {
            guard !Task.isCancelled else {
                return false
            }
            queueAt += 1
            do {
                switch item.contentType {
                case .png, .jpeg, .webp,.heic: // 사진
                    try await image(item.imageURL)
                case .mp4:                     // 영상
                    try await video(item.imageURL)
                }
                
                completedDownloadCount += 1
                remainingDownloadCount = Int64(queue.count)
                
                completeCounting(
                    completedDownloadCount + remainingDownloadCount,
                    completedDownloadCount
                )
            } catch {
                success = false
                print("미디어 저장 실패:", error)
            }
        }
        return success
    }
    

    private func image(_ url: URL) async throws {
        try Task.checkCancellation()
        
        // Kingfisher: 메모리/디스크 캐시 우선 → 없으면 네트워크
        let result = try await KingfisherManager.shared.retrieveImage(
            with: url
        )
        
        try Task.checkCancellation()

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(
                from: result.image
            )
        }
    }
    
    private func video(_ url: URL) async throws {
        
        try Task.checkCancellation()
        
        let (temporaryURL, response) = try await URLSession.shared.download(
            from: url
        )
        
        guard let response = response as? HTTPURLResponse,
              200..<300 ~= response.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        try Task.checkCancellation()
        
        try await PHPhotoLibrary.shared().performChanges {
            guard PHAssetChangeRequest.creationRequestForAssetFromVideo(
                atFileURL: temporaryURL
            ) != nil else {
                return
            }
        }
        
    }
    
    // 실제 Background Task 스케쥴러를 실행하는 함수
    private func submitBackgroundDownload() async throws {
        let request = BGContinuedProcessingTaskRequest(
            identifier: identifier,
            title: "미디어 다운로드",
            subtitle: "사진과 영상을 저장하고 있습니다."
        )

        // .queue: 바로 실행이 불가능하면 대기열에 넣음, fail:
        request.strategy = .queue

        try await BGTaskScheduler.shared.submitTaskRequest(request)
    }
}

extension FeedDownloader {
    
    func enqueue(_ feeds: [FeedImageEntity]) {
        feeds.enumerated().forEach { queue[$0.offset + waitAt] = $0.element }
        waitAt += feeds.count
        requestStartIfNeeded()
    }
    
    func enqueue(_ feed: FeedImageEntity) {
        self.queue[1 + self.waitAt] = feed
        self.waitAt += 1
        requestStartIfNeeded()
    
    }
    
    private func requestStartIfNeeded()  {
        guard state == .idle else { return }
        guard queue[queueAt + 1] != nil else { return }     // 현재 진행중인 작업에서 다음 작업이 있는지 확인

        state = .requested

        Task {
            do {
                try await submitBackgroundDownload()
            } catch {
                // 에러 처리
                print("백그라운드 작업 요청 실패:", error)
                let success = await start { t, c in
                    print("일반 다운로드 진행 중 결과: \(t)개중 \(c)개 완료")
                }
                print("일반 다운로드 결과:", success)
            }
        }
    }
}

private extension FeedDownloader {
    private enum ProcessingState {
        case idle
        case requested
        case running
    }
}
