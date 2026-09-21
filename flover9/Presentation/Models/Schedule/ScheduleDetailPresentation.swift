//
//  ScheduleDetailPresentation.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
import Foundation

/// 일정의 시간대와 상태를 반영한 상세 화면 표시값.
struct ScheduleDetailPresentation {
    let title: String           // 제목
    let category: ScheduleType  // 일정 타입
    let status: ScheduleStatus  // 일정 상태
    let needsAttention: Bool    // 일정이 캔슬, 연기, 지연 되었을 경우
    let date: String            // 날짜
    let time: String            // 시간 (ex: 18:00 - 19:00)
    let venue: String           // 장소명
    let address: String?        // 주소
    let imageURLs: [URL]        // 상세 페이지 이미지 URL
    let bannerImageURL: URL?    // 배너 사진
    let canReserve: Bool        // 바로가기 주소 유무
    let description: String?    // 설명 및 소개

    init(content: ScheduleDetailContent) {
        self.title = content.schedule.title
        let schedule = content.schedule
        category = schedule.type
        status = schedule.status
        needsAttention = [.cancelled, .postponed, .delayed].contains(schedule.status)
        (date, time) = Self.dateAndTime(schedule)
        venue = Self.nonempty(schedule.venueName) ?? "장소가 아직 정해지지 않았어요"
        address = Self.nonempty(content.detail?.roadAddress)
            ?? Self.nonempty(content.detail?.address)

        // 같은 URL이 대표 이미지와 첨부 미디어에 함께 있어도 한 번만 표시한다.
        var seen = Set<URL>()
        let mediaURLs = content.media.sorted { $0.sortOrder < $1.sortOrder }.compactMap {
            $0.mediaType == .image ? $0.mediaURL : $0.thumbnailURL
        }
        let candidates = mediaURLs.isEmpty
            ? [schedule.thumbnailURL].compactMap { $0 }
            : mediaURLs
        imageURLs = candidates.filter { seen.insert($0).inserted }
        
        bannerImageURL = content.media
            .first { $0.displayRole == .hero }?
            .mediaURL
        

        let reservationURL = content.detail?.reservationURL
        let scheme = reservationURL?.scheme?.lowercased()
        canReserve = (scheme == "https" || scheme == "http")
            && reservationURL?.host?.isEmpty == false
            && schedule.status != .cancelled
            && schedule.status != .completed
        
        description = content.detail?.description
    }

    static func nonempty(_ text: String?) -> String? {
        let value = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        return value?.isEmpty == false ? value : nil
    }
}

private extension ScheduleDetailPresentation {

    static func dateAndTime(_ schedule: ScheduleEntity) -> (String, String) {
        let zone = TimeZone(identifier: schedule.timeZone) ?? .current
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = zone
        formatter.dateFormat = "yyyy. M. d (E)"
        let startDate = formatter.string(from: schedule.startAt)
        let isMultipleDays = schedule.endAt.map {
            !calendar.isDate(schedule.startAt, inSameDayAs: $0)
        } ?? false
        let date = if isMultipleDays, let endAt = schedule.endAt {
            "\(startDate) –\n\(formatter.string(from: endAt))"
        } else {
            startDate
        }

        formatter.dateFormat = "a h:mm"
        let zoneLabel = zone.abbreviation(for: schedule.startAt) ?? schedule.timeZone
        let operationStart = operationTime(schedule.operationStartTime, formatter: formatter)
        let operationEnd = operationTime(schedule.operationEndTime, formatter: formatter)
        let operationPrefix = isMultipleDays ? "매일 " : ""
        let time: String
        if let operationStart, let operationEnd {
            time = "\(operationPrefix)\(operationStart) – \(operationEnd)"
        } else if let operationStart {
            time = "\(operationPrefix)\(operationStart)부터"
        } else if let operationEnd {
            time = "\(operationPrefix)\(operationEnd)까지"
        } else if schedule.isAllDay {
            return (date, "종일")
        } else if let endAt = schedule.endAt {
            let startTime = formatter.string(from: schedule.startAt)
            let endTime = formatter.string(from: endAt)
            time = isMultipleDays
                ? "첫날 \(startTime) · 마지막 날 \(endTime)"
                : "\(startTime) – \(endTime)"
        } else {
            time = "\(formatter.string(from: schedule.startAt)) 시작"
        }
        return (date, "\(time) · \(zoneLabel)")
    }

    // DB의 time 값은 일시와 별개인 현지 운영 시간이므로 시간대를 재변환하지 않는다.
    static func operationTime(_ value: String?, formatter: DateFormatter) -> String? {
        guard let value else { return nil }
        let parts = value.split(separator: ":")
        guard parts.count >= 2,
              let hour = Int(parts[0]), (0...23).contains(hour),
              let minute = Int(parts[1]), (0...59).contains(minute)
        else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = formatter.timeZone
        guard let date = calendar.date(from: DateComponents(
            year: 2000, month: 1, day: 1, hour: hour, minute: minute
        )) else { return nil }
        return formatter.string(from: date)
    }
}
