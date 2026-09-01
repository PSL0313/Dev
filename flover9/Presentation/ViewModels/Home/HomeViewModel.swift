//
//  HomeViewModel.swift
//  flover9
//
//  Created by 박선린 on 8/11/26.
//

import Foundation
import UIKit
import MusicKit

// MARK: - HomeViewModel
final class HomeViewModel {
    // MARK: - Route
    enum Route {
        case fetchedHomeData    // 홈데이터 모두 fetch 완료
        case failed(String)             // 홈탭 데이터 fetch 실패
        case moveToMemberProfileView(MemberEntity)
    }

    // MARK: - Input
    enum Input {
        case start
        case moveToMember(MemberEntity)
        case moveToSchedule(UUID)
        case moveToAllSchedule
    }
    // MARK: - State
    enum State {
        case fetchedHomeData
        case fetchedAlbumData
    }
    // MARK: - Coordinator에게 전달할 이벤트
    var onRoute: ((Route) -> Void)?
    var onState: ((State) -> Void)?

    // MARK: - UseCase
    private let fetchMembersUseCase: FetchMembersUseCaseProtocol
    private let fetchScheduleCoversUseCase: FetchScheduleCoversUseCaseProtocol

    // MARK: - Store
    private let musicAlbumStore: MusicAlbumStoreProtocol

    // MARK: - Service
    private let appleMusicCatalogService: AppleMusicCatalogService

    // MARK: - Properties
    private(set) var members: [MemberEntity] = [] // 화면 데이터 보관
    private(set) var homeSchedulesCardData: [HomeScheduleCardModel] = [] // 화면 데이터 보관
    private(set) var albums: [Album] = []
    private(set) var others: [Album] = []
    var memberCount: Int {
        members.count
    }

    private var task: Task<Void, Error>?

    // MARK: - Initializer
    init(
        fetchMembersUseCase: FetchMembersUseCaseProtocol,
         fetchScheduleCoversUseCase: FetchScheduleCoversUseCaseProtocol,
        musicAlbumStore: MusicAlbumStoreProtocol,
        appleMusicCatalogService: AppleMusicCatalogService
    ) {
        self.fetchMembersUseCase = fetchMembersUseCase
        self.fetchScheduleCoversUseCase = fetchScheduleCoversUseCase
        self.musicAlbumStore = musicAlbumStore
        self.appleMusicCatalogService = appleMusicCatalogService
    }

    // MARK: - deinit
    deinit { print("HomeViewModel deinit") }

    func action(_ input: Input) {
        switch input {
        case .start:
            start()
        case .moveToMember(let member):
            onRoute?(.moveToMemberProfileView(member))
        case .moveToAllSchedule:
            ()
        case .moveToSchedule(let scheduleId):
            print(scheduleId)
        }
    }

    // MARK: - ViewController가 사용할 함수
    func member(at index: Int) -> MemberEntity? {
        guard members.indices.contains(index) else {
            return nil
        }

        return members[index]
    }
}

private extension HomeViewModel {
    func start() {
        self.task = Task {
            do {
                // 구조적 병렬 작업 시작
                async let membersTask: [MemberEntity] = fetchMembersUseCase.execute()
                fetchAlbums()

                let (members) = try await (
                    membersTask
                )

                async let schedules: [HomeScheduleCardModel] = fetchScheduleCoversUseCase.execute(members)

                // 변수 저장
                self.members = members
                self.homeSchedulesCardData = try await schedules

                // 뷰컨에게 전달
                onState?(.fetchedHomeData)

                // 코디네이터에게 전달(스플래쉬뷰 종료 요청)
                onRoute?(.fetchedHomeData)
            } catch let error as MemberError {
                onRoute?(Route.failed(error.userMessage))
            } catch let error as ScheduleError {
                onRoute?(Route.failed(error.userMessage))
            }  catch let error as AppleMusicCatalogError {
                onRoute?(Route.failed(error.message))
            } catch {
                onRoute?(Route.failed(MemberError.unknown.userMessage))
            }
        }
    }
}

// MARK: - 앨범 정보 관련(애플 뮤직킷
private extension HomeViewModel {

    func fetchAlbums() {
        Task {
            do {
                async let fetchAlbums = self.musicAlbumStore.albums()
                async let fetchOthers = self.musicAlbumStore.otherAlbums()

                let (albums, others) = await (fetchAlbums, fetchOthers)

                self.albums = try await appleMusicCatalogService.fetchAlbums(from: albums)
                self.others = try await appleMusicCatalogService.fetchAlbums(from: others)

                onState?(.fetchedAlbumData)
            } catch {
                onRoute?(.failed("앨범 정보 불러오기 실패"))
            }
        }
    }
}

extension HomeViewModel {
    // MARK: - 홈 화면에 표시할 데이터 묶음
    struct HomeData: Sendable, Equatable {
        let members: [MemberEntity] // 멤버 목록
        let upComingSchedules: [ScheduleEntity] // 가까운 스케쥴
    }
}
