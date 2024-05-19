//
//  BusStopDetailVIew.swift
//  my_traffic3
//
//  Created by yhl on 5/19/24.
//

import SwiftUI
import CoreData

struct AlertMessage: Identifiable {
    var id = UUID()
    var message: String
}

struct BusStopDetailView: View {
    var busStop: BusStop
    @State private var busRoutes: [BusRoute] = []
    @Binding var showingDetail: Bool
    @State private var selectedRoutes: Set<BusRoute> = []
    @State private var alertMessage: AlertMessage?

    var body: some View {
        VStack {
            HStack {
                Button("취소") {
                    showingDetail = false
                }
                Spacer()
                VStack {
                    Text("\(busStop.stationName ?? "") (\(busStop.mobileNo ?? ""))")
                        .font(.headline)
                }
                Spacer()
                Button("저장") {
                    saveBusStop()
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))

            List(busRoutes, id: \.routeId) { busRoute in
                HStack {
                    Image(systemName: selectedRoutes.contains(busRoute) ? "checkmark.square" : "square")
                        .onTapGesture {
                            if selectedRoutes.contains(busRoute) {
                                selectedRoutes.remove(busRoute)
                            } else {
                                selectedRoutes.insert(busRoute)
                            }
                        }
                    VStack(alignment: .leading) {
                        Text("노선 번호: \(busRoute.routeName ?? "")")
                        Text("노선 타입: \(busRoute.routeTypeCd ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedRoutes.contains(busRoute) {
                        selectedRoutes.remove(busRoute)
                    } else {
                        selectedRoutes.insert(busRoute)
                    }
                }
            }
        }
        .onAppear {
            fetchBusRoutes()
        }
        .alert(item: $alertMessage) { alertMessage in
            Alert(title: Text(alertMessage.message))
        }
    }

    func fetchBusRoutes() {
        guard let stationId = busStop.stationId else { return }
        APIService.shared.fetchBusRoutes(stationId: stationId) { busRoutes in
            self.busRoutes = busRoutes
        }
    }

    func saveBusStop() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<BusStop> = BusStop.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "stationId == %@", busStop.stationId ?? "")

        do {
            let existingBusStops = try context.fetch(fetchRequest)
            if !existingBusStops.isEmpty {
                // 이미 존재하는 정류장
                alertMessage = AlertMessage(message: "이미 있는 정류장")
            } else {
                // 정류장이 없을 경우 저장
                let newBusStop = BusStop(context: context)
                newBusStop.mobileNo = busStop.mobileNo
                newBusStop.stationId = busStop.stationId
                newBusStop.stationName = busStop.stationName
                
                for route in selectedRoutes {
                    let newRoute = BusRoute(context: context)
                    newRoute.routeId = route.routeId
                    newRoute.routeName = route.routeName
                    newRoute.routeTypeCd = route.routeTypeCd
                    newBusStop.addToRoutes(newRoute)
                }

                try context.save()
                alertMessage = AlertMessage(message: "\(busStop.stationName ?? "") 저장됨")
                showingDetail = false // 저장 후 시트 닫기
            }
        } catch {
            print("Failed to save bus stop: \(error)")
        }

        // 메시지를 잠시 동안만 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            alertMessage = nil
        }
    }
}
