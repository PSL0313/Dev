//
//  MemberRepository.swift
//  flover9
//
//  Created by 박선린 on 8/11/26.
//

// MARK: - 멤버 DataSource의 DTO를 Domain Entity로 변환하는 저장소
final class MemberRepository: MemberRepositoryProtocol {
    private let dataSource: MemberRemoteDataSourceProtocol // 원격 멤버 데이터 제공자

    init(dataSource: MemberRemoteDataSourceProtocol) {
        self.dataSource = dataSource // 외부에서 주입받은 데이터 제공자 보관
    }

    func fetchMembers() async throws -> [MemberEntity] {
        do {
            let members = try await dataSource.getMembers() // 원격 DTO 목록 조회
            return try members.map { try $0.toEntity() }    // Domain Entity로 변환
        } catch let error as MemberError {
            throw error                                     // 이미 분류된 Domain 오류 유지
        } catch {
            throw mapMemberError(error)                     // Data 오류를 Domain 오류로 변환
        }
    }

    func fetchMember(code: MemberCode) async throws -> MemberEntity {
        do {
            let member = try await dataSource.getMember(code: code) // 특정 멤버 DTO 조회
            return try member.toEntity()                            // Domain Entity로 변환
        } catch let error as MemberError {
            throw error                                             // 이미 분류된 Domain 오류 유지
        } catch {
            throw mapMemberError(error)                             // Data 오류를 Domain 오류로 변환
        }
    }

    // MARK: - Data 계층 오류를 멤버 Domain 오류로 변환
    private func mapMemberError(_ error: Error) -> MemberError {
        guard let dataError = error as? SupabaseDataError else {
            return .unknown // 예상하지 못한 외부 오류
        }

        switch dataError {
        case .network:
            return .networkUnavailable
        case .unauthorized:
            return .permissionDenied
        case .notFound:
            return .notFound
        case .decoding:
            return .invalidMemberData
        case .database:
            return .serverUnavailable
        case .unknown:
            return .unknown
        }
    }
}
