//
//  APODApp.swift
//  APOD
//
//  Created by Izumu Mishima on 28/06/2020.
//

import SwiftUI

@main
struct APODApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @State var apodItem = APODItem()
    
    var body: some Scene {
        WindowGroup {
            ContentView(apodItem: apodItem)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                loadAPOD()
            }
        }
    }
    
    func loadAPOD() {
        APODFetcher.loadAPODFromAPIWithoutImages { (apod, error) in
            if let apod = apod {
                apodItem = apod
            } else {
                if apodItem == APODItem() {
                    apodItem = APODItem(explanation: "Couldn't load")
                }
            }
		}
    }
}
