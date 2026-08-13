//
//  HomeViewModel.swift
//  flover9
//
//  Created by 박선린 on 8/11/26.
//

import Foundation
import UIKit

// MARK: - HomeViewModel
final class HomeViewModel {
    // MARK: - Route
    enum Route {
        case fetchedHomeData    // 홈데이터 모두 fetch 완료
        case failed(String)             // 홈탭 데이터 fetch 실패
    }
    
    // MARK: - Input
    enum Input {
        case start
    }
    // MARK: - State
    enum State {
        case fetchedHomeData
    }
    // MARK: - Coordinator에게 전달할 이벤트
    var onRoute: ((Route) -> Void)?
    var onState: ((State) -> Void)?
    
    // MARK: - UseCase
    private var fetchMembersUseCase: FetchMembersUseCaseProtocol
    private var fetchScheduleCoversUseCase: FetchScheduleCoversUseCaseProtocol
    
    // MARK: - Properties
    private(set) var members: [MemberEntity] = [] // 화면 데이터 보관
    private(set) var schedules: [ScheduleEntity] = [] // 화면 데이터 보관
    
    var memberCount: Int {
        members.count
    }
    
    private var task: Task<Void, Error>?
    
    // MARK: - Initializer
    init(
        fetchMembersUseCase: FetchMembersUseCaseProtocol,
         fetchScheduleCoversUseCase: FetchScheduleCoversUseCaseProtocol
    ) {
        self.fetchMembersUseCase = fetchMembersUseCase
        self.fetchScheduleCoversUseCase = fetchScheduleCoversUseCase
    }
    
    // MARK: - deinit
    deinit { print("HomeViewModel deinit") }

    func action(_ input: Input) {
        switch input {
        case .start:
            start()
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
                async let schedulesTask: [ScheduleEntity] = fetchScheduleCoversUseCase.execute()

                let (members, draftSchedules) = try await (
                    membersTask,
                    schedulesTask
                )
                
                let schedules = memberSortOrder(member: members, schedules: draftSchedules)
                
                // 변수 저장
                self.members = members
                self.schedules = schedules
                
                // 뷰컨에게 전달
                onState?(.fetchedHomeData)
                
                // 코디네이터에게 전달
                onRoute?(.fetchedHomeData)
            } catch let error as MemberError {
                onRoute?(Route.failed(error.userMessage))
            } catch let error as ScheduleError {
                onRoute?(Route.failed(error.userMessage))
            } catch {
                onRoute?(Route.failed(MemberError.unknown.userMessage))
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
    
    private func memberSortOrder(member: [MemberEntity], schedules: [ScheduleEntity]) -> [ScheduleEntity] {
        var answer: [ScheduleEntity] = []
        // MARK: - 멤버의 공식 정렬 순서 생성
        let memberSortOrder = Dictionary(
            uniqueKeysWithValues: members.map {
                ($0.code, $0.sortOrder)
            }
        )
        for schedule in schedules {
            guard let memberCodes = schedule.participantMemberCodes else { continue }
            
            // 참여 멤버 코드를 공식 순서대로 정렬
            let sortedMemberCodes = memberCodes.sorted {
                let lhsOrder = memberSortOrder[$0] ?? Int.max
                let rhsOrder = memberSortOrder[$1] ?? Int.max

                return lhsOrder < rhsOrder
            }
            
            answer.append(ScheduleEntity(
                id: schedule.id,
                title: schedule.title,
                venueName: schedule.venueName,
                type: schedule.type,
                status: schedule.status,
                startAt: schedule.startAt,
                endAt: schedule.endAt,
                isAllDay: schedule.isAllDay,
                operationStartTime: schedule.operationStartTime,
                operationEndTime: schedule.operationEndTime,
                timeZone: schedule.timeZone,
                thumbnailURL: schedule.thumbnailURL,
                externalURL: schedule.externalURL,
                externalContentID: schedule.externalContentID,
                participantMemberCodes: sortedMemberCodes,
                createdAt: schedule.createdAt,
                updatedAt: schedule.updatedAt
            ))
        }
        return answer
    }
}
