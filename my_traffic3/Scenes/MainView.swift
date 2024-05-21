//
//  MainView.swift
//  my_traffic3
//
//  Created by yhl on 5/19/24.
//

import SwiftUI
import CoreData

struct MainView: View {
    @FetchRequest(
        entity: BusStop.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \BusStop.stationName, ascending: true)]
    ) var busStops: FetchedResults<BusStop>

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
                    NavigationLink(destination: SearchView()) {
                        Image(systemName: "tram.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)

                    Spacer()

                    NavigationLink(destination: SearchView()) {
                        Image(systemName: "bus.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            }
            .navigationTitle("위젯 설정")
        }
    }
}

extension BusStop {
    var routesArray: [BusRoute] {
        let set = routes as? Set<BusRoute> ?? []
        return set.sorted {
            $0.routeName ?? "" < $1.routeName ?? ""
        }
    }
}
