//
//  RouteSelectionView.swift
//  my_traffic3
//
//  Created by yhl on 5/19/24.
//

import SwiftUI
import CoreData

struct RouteSelectionView: View {
    var busStop: BusStop
    @State private var busRoutes: [BusRoute] = [] // 상태 변수로 busRoutes 추가
    @State private var selectedRoutes: Set<BusRoute> = [] // 선택된 노선들을 저장할 상태 변수

    var body: some View {
        VStack {
            List(busRoutes, id: \.routeId, selection: $selectedRoutes) { busRoute in
                VStack(alignment: .leading) {
                    Text("노선 번호: \(busRoute.routeName ?? "")")
                    Text("노선 타입: \(busRoute.routeTypeCd ?? "")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle(busStop.stationName ?? "")
        .navigationBarItems(trailing: Button("저장") {
            saveSelectedRoutes()
        })
        .onAppear {
            fetchBusRoutes()
        }
    }

    func fetchBusRoutes() {
        // API 요청 및 데이터 파싱 로직 추가
        // 예시 데이터로 채우기:
        let exampleRoutes = [
            BusRoute(context: PersistenceController.shared.container.viewContext),
            BusRoute(context: PersistenceController.shared.container.viewContext)
        ]
        exampleRoutes[0].routeId = "900"
        exampleRoutes[0].routeName = "900"
        exampleRoutes[0].routeTypeCd = "13"
        exampleRoutes[1].routeId = "033"
        exampleRoutes[1].routeName = "033"
        exampleRoutes[1].routeTypeCd = "30"
        
        self.busRoutes = exampleRoutes
    }

    func saveSelectedRoutes() {
        // CoreData 저장 로직 추가
        let context = PersistenceController.shared.container.viewContext
        for route in selectedRoutes {
            busStop.addToRoutes(route)
        }

        do {
            try context.save()
        } catch {
            // 에러 처리
            print("Failed to save selected routes: \(error)")
        }
    }
}

//struct RouteSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = PersistenceController.preview.container.viewContext
//        let busStop = BusStop(context: context)
//        busStop.stationId = "12345"
//        busStop.stationName = "Sample Station"
//        busStop.mobileNo = "67890"
//        
//        return RouteSelectionView(busStop: busStop)
//            .environment(\.managedObjectContext, context)
//    }
//}
