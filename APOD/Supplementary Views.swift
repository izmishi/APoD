//
//  Supplementary Views.swift
//  APOD
//
//  Created by Izumu Mishima on 29/06/2020.
//

import SwiftUI

struct ScrollableImage: View {
    var image: Image
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView([.vertical, .horizontal]) {
                image
            }
            
            Button {
                self.isPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color(UIColor.systemBackground))
                    .font(.title)
                    .shadow(color: Color(UIColor.secondaryLabel), radius: 4)
                    .padding()
            }
            
        }
    }
}

struct APODImage: View {
    var image: UIImage
    @State private var fullImageIsPresented = false
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture {
                fullImageIsPresented.toggle()
            }
            .sheet(isPresented: $fullImageIsPresented) {
                ScrollableImage(image: Image(uiImage: image), isPresented: $fullImageIsPresented)
            }
    }
}

struct PlaceholderImage: View {
    var systemIconName: String = "photo.fill"
    var type: APODItem.MediaType
    var showsPlaceholderText: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemBackground))
            VStack {
                Spacer()
                
                Image(systemName: systemIconName)
                    .font(.largeTitle)
                
                Spacer()
                
                if case APODItem.MediaType.unknown(let unknownType) = type {
                    if unknownType != "" {
                        Text("Unknown media type: \(unknownType)")
                            .font(.headline)
                    }
                }
            }
            .foregroundColor(Color(UIColor.systemFill))
            .padding()
        }
    }
}

struct VideoThumbnail: View {
    var thumbnail: UIImage
    
    private var lightIcon: Bool {
        if let brightness = thumbnail.averageBrightness {
            return brightness < 0.5
        }
        return true
    }
    
    var body: some View {
        ZStack {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Image(systemName: "video.fill")
                .font(.largeTitle)
                .foregroundColor(lightIcon ? .white : .black)
                .shadow(color: lightIcon ? .black : .white, radius: 8)
        }
    }
}

struct BoldLabelText: View {
    var boldLabel: String
    var text: String
    
    var body: some View {
        Text("\(boldLabel) ").bold() + Text(text)
    }
}


struct APODMediaView: View {
    var image: UIImage?
    var imageURL: URL?
    var mediaType: APODItem.MediaType
    
    var body: some View {
        Group {
            if let image = image {
                switch mediaType {
                case .image:
                    APODImage(image: image)
                case .gif:
                    GeometryReader { geometry in
                        GIFView(gifImage: image, width: geometry.size.width)
                        //							.frame(width: geometry.size.width)
                    }
                    
                case .video:
                    Link(destination: imageURL ?? APODFetcher.apodURL) {
                        VideoThumbnail(thumbnail: image)
                    }
                case .unknown(_):
                    APODImage(image: image)
                }
                
            } else {
                switch mediaType {
                case .image, .gif:
                    PlaceholderImage(type: .image)
                case .video:
                    PlaceholderImage(systemIconName: "video.fill", type: .video)
                case .unknown(_):
                    PlaceholderImage(systemIconName: "questionmark.square.dashed", type: mediaType)
                }
            }
        }
    }
}

struct ScrollableImage_Previews: PreviewProvider {
    static var previews: some View {
        ScrollableImage(image: Image(systemName: "photo.fill"), isPresented: .constant(true))
    }
}
