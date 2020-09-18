//
//  APODApp.swift
//  APOD
//
//  Created by Izumu Mishima on 28/06/2020.
//

import SwiftUI

@main
struct APODApp: App {
	
	@State var apodItem = APODItem()
	
    var body: some Scene {
        WindowGroup {
			ContentView(apodItem: apodItem)
				.onAppear {
					APODFetcher.loadCurrentAPOD { (apod, error) in
						if let apod = apod {
							apodItem = apod
						} else {
							apodItem = APODItem(explanation: "Couldn't load")
						}
					}
				}
		}
    }
}
