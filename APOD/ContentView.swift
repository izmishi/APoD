//
//  ContentView.swift
//  APOD
//
//  Created by Izumu Mishima on 28/06/2020.
//

import SwiftUI

struct ContentView: View {
    var apodItem: APODItem
    
    @State var fullImageIsPresented = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(apodItem.title)
                    .font(.title)
                    .bold()
                
                Text(apodItem.date, style: .date)
                    .font(Font.callout.lowercaseSmallCaps())
                    .bold()
                
                APODMediaView(image: apodItem.image, imageURL: apodItem.imageURL, mediaType: apodItem.mediaType)
                    .padding(.top)
                
                BoldLabelText(boldLabel: apodItem.imageCreditLabel, text: apodItem.imageCredit)
                    .font(.caption)
                    .padding(.bottom)
                
                BoldLabelText(boldLabel: "Explanation:", text: apodItem.explanation)
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                
                Link("APOD Website", destination: URL(string: "https://apod.nasa.gov/apod/astropix.html")!)
                    .font(.callout)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
            }
            .padding()
        }
        .clipped()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(apodItem: APODItem())
    }
}

