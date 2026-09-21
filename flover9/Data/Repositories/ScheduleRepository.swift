//
//  ScheduleRepository.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//

import Foundation

// MARK: - 메모리 캐시 우선 조회 및 일정 DTO의 Domain 변환 담당
final class ScheduleRepository: ScheduleRepositoryProtocol {
    private let dataSource: ScheduleRemoteDataSourceProtocol
    private let cache: ScheduleCacheProtocol
    // 초기화 전에 시작된 요청이 완료되어도 이전 데이터를 다시 캐싱하지 않는다.
    private var cacheGeneration: UInt = 0

    init(dataSource: ScheduleRemoteDataSourceProtocol, cache: ScheduleCacheProtocol) {
        self.dataSource = dataSource
        self.cache = cache
    }

    // MARK: - 표지에서 사용할 일정 요약 목록 조회
    func fetchScheduleCovers() async throws -> [ScheduleEntity] {
        do {
            let generation = cacheGeneration
            if let schedules = await cache.covers() {
                return schedules.map { $0.toEntity() }
            }

            let schedules = try await dataSource.fetchScheduleCovers()
            guard schedules.allSatisfy({ $0.eventID == $0.event.id }) else {
                throw ScheduleError.invalidScheduleData
            }
            if generation == cacheGeneration {
                await cache.saveCovers(schedules)
            }
            return schedules.map { $0.toEntity() }
        } catch let error as ScheduleError {
            throw error                                              // 이미 분류된 Domain 오류 유지
        } catch {
            throw mapScheduleError(error)                            // Data 오류를 Domain 오류로 변환
        }
    }

    // MARK: - 상세 화면에서 사용할 일정 정보 묶음 조회
    func fetchScheduleDetail(scheduleID: UUID) async throws -> ScheduleDetailContent {
        do {
            let generation = cacheGeneration
            if let response = await cache.detail(for: scheduleID) {
                return response.toEntity()
            }

            // 홈에서 이미 조회한 일정 요약은 재사용한다.
            let schedule: ScheduleDTO
            if let cachedSchedule = await cache.schedule(for: scheduleID) {
                schedule = cachedSchedule
            } else {
                schedule = try await dataSource.fetchSchedule(id: scheduleID)
            }
            guard schedule.id == scheduleID, schedule.eventID == schedule.event.id else {
                throw ScheduleError.invalidScheduleData
            }
            async let detailDTO = dataSource.fetchScheduleDetail(scheduleID: scheduleID)
            async let mediaDTOs = dataSource.fetchScheduleMedia(scheduleID: scheduleID, eventID: schedule.eventID)

            let (detail, media) = try await (
                detailDTO,
                mediaDTOs
            )

            guard detail == nil || detail?.scheduleID == scheduleID else {
                throw ScheduleError.invalidScheduleData
            }
            let response = ScheduleDetailResponseDTO(
                schedule: schedule,
                detail: detail,
                media: media
            )
            // 일부 요청이 실패한 경우에는 불완전한 상세 결과를 저장하지 않는다.
            if generation == cacheGeneration {
                await cache.saveDetail(response)
            }
            return response.toEntity()
        } catch let error as ScheduleError {
            throw error                                              // 이미 분류된 Domain 오류 유지
        } catch {
            throw mapScheduleError(error)                            // Data 오류를 Domain 오류로 변환
        }
    }

    // MARK: - Reset
    func resetCovers() async {
        cacheGeneration &+= 1
        await cache.resetCovers()
    }

    func reset(scheduleID: UUID) async {
        cacheGeneration &+= 1
        await cache.reset(scheduleID)
    }

    func resetAll() async {
        cacheGeneration &+= 1
        await cache.resetAll()
    }

    // MARK: - 범용 Supabase Data 오류를 일정 Domain 오류로 변환
    private func mapScheduleError(_ error: Error) -> ScheduleError {
        guard let dataError = error as? SupabaseDataError else {
            return .unknown                                         // 예상하지 못한 외부 오류
        }

        switch dataError {
        case .network:
            return .networkUnavailable
        case .unauthorized:
            return .permissionDenied
        case .notFound:
            return .notFound
        case .decoding:
            return .invalidScheduleData
        case .database:
            return .serverUnavailable
        case .unknown:
            return .unknown
        }
    }
}
