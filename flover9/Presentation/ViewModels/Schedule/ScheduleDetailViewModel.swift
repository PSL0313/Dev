//
//  ScheduleDetailViewModel.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
import Foundation
import MapKit

@MainActor
final class ScheduleDetailViewModel {
    enum Input {
        case start
        case retry
        case reservationButtonTapped
        case calendarAddButtonTapped
    }

    enum State {
        case loading
        case loaded(ScheduleDetailContent, MKMapItem?)
        case failed(String)
        case calendarEventReady(CalendarEventModel)
    }

    enum Route {
        case openReservation(URL)
        case calendarAddFailed(String)
    }

    var onState: ((State) -> Void)?
    var onRoute: ((Route) -> Void)?

    private let scheduleID: UUID
    private var content: ScheduleDetailContent?
    private var mapItem: MKMapItem?
    
    private let fetchScheduleDetailUseCase: FetchScheduleDetailUseCaseProtocol
    private let mapItemUseCase: MapItemUseCaseProtocol
    private let errorLogger: ErrorLogging
    private var loadTask: Task<Void, Never>?
    private var calendarAddTask: Task<Void, Never>?
    

    init(
        scheduleID: UUID,
        fetchScheduleDetailUseCase: FetchScheduleDetailUseCaseProtocol,
        mapItemUseCase: MapItemUseCaseProtocol,
        errorLogger: ErrorLogging
    ) {
        self.scheduleID = scheduleID
        self.fetchScheduleDetailUseCase = fetchScheduleDetailUseCase
        self.mapItemUseCase = mapItemUseCase
        self.errorLogger = errorLogger
    }

    deinit {
        loadTask?.cancel()
        print("ScheduleDetailViewModel deinit")
    }

    func action(_ input: Input) {
        switch input {
        case .start, .retry:
            load()
        case .reservationButtonTapped:
            openReservation()
        case .calendarAddButtonTapped:
            addScheduleToCalendar()
        }
    }

    func cancelLoading() {
        loadTask?.cancel()
        calendarAddTask?.cancel()
    }
}

private extension ScheduleDetailViewModel {
    func load() {
        guard loadTask == nil else { return }

        onState?(.loading)
        loadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer { loadTask = nil }

            do {
                let content = try await fetchScheduleDetailUseCase.execute(
                    scheduleID: scheduleID
                )
                self.content = content

                
                guard !Task.isCancelled else { return }

                let scheduleID = content.detail?.scheduleID ?? content.schedule.id
                
                var location: CLLocation?
                
                if let longitude = content.detail?.longitude,
                   let latitude = content.detail?.latitude {
                    location = CLLocation(
                        latitude: latitude,
                        longitude: longitude
                    )
                }
                
                let applePlaceID = content.detail?.applePlaceID
                
                // 중요도가 낮아 에러 발생시 그냥 nil로 처리하고 지도를 화면에 표시하지 않는다
                let mapItem = try? await mapItemUseCase.execute(
                    id: scheduleID,
                    location: location,
                    applePlaceID: applePlaceID
                )
                self.mapItem = mapItem
                
                guard !Task.isCancelled else { return }
                
                onState?(.loaded(content, mapItem))
            } catch let error as ScheduleError {
                
                guard !Task.isCancelled else { return }
                onState?(.failed(error.userMessage))
                await errorLogger.record(error)
                
            } catch {
                
                guard !Task.isCancelled else { return }
                onState?(.failed(ScheduleError.unknown.userMessage))
                await errorLogger.record(ScheduleError.unknown)
                
            }
        }
    }

    func openReservation() {
        guard
            let content,
            content.schedule.status != .cancelled,
            content.schedule.status != .completed,
            let url = content.detail?.reservationURL,
            url.host?.isEmpty == false,
            let scheme = url.scheme?.lowercased(),
            scheme == "https" || scheme == "http"
        else {
            return
        }
        onRoute?(.openReservation(url))
    }
    
    func addScheduleToCalendar()  {
        guard let content else { return }
        
        let geoLocation: CLLocation?

        if let latitude = content.detail?.latitude,
           let longitude = content.detail?.longitude {

            geoLocation = CLLocation(
                latitude: latitude,
                longitude: longitude
            )
        } else {
            geoLocation = nil
        }
        
        let model = CalendarEventModel(
            title: content.schedule.title,
            startDate: content.schedule.startAt,
            endDate: content.schedule.endAt,
            isAllDay: content.schedule.isAllDay,
            timeZone: TimeZone(identifier: content.schedule.timeZone),
            location: content.schedule.venueName,
            notes: content.detail?.description,
            url: content.detail?.reservationURL,
            mapItem: self.mapItem
        )
        
        onState?(.calendarEventReady(model))
        
    }
    
}
