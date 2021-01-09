//
//  ContentView.swift
//  APOD
//
//  Created by Izumu Mishima on 28/06/2020.
//

import SwiftUI

enum ImageQuality {
	case high
	case low
}

var tasks: [(URLSessionDownloadTask, (UIImage?) -> Void, Date, URL, ImageQuality, (Double) -> Void)] = []
var pausedTasks: [URLSessionDownloadTask: Data] = [:]

struct ContentView: View {
	var apodItem: APODItem
    
    @State private var fullImageIsPresented = false
	
	@State private var lowResProgress: Double = 0
	@State private var highResProgress: Double = 0
	
	@State private var lowResImage: UIImage?
	@State private var highResImage: UIImage?
	
	@State private var lowResObservation: NSKeyValueObservation?
	@State private var highResObservation: NSKeyValueObservation?
	
	@Environment(\.scenePhase) private var scenePhase
	
	var showsProgressBar: Bool {
		max(lowResProgress, highResProgress) > 0 && min(lowResProgress, highResProgress) < 1 && highResImage == nil
	}
    
    var body: some View {
		ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text(apodItem.title)
                    .font(.title)
                    .bold()
                
                Text(apodItem.date, style: .date)
                    .font(Font.callout.lowercaseSmallCaps())
                    .bold()
                
				ZStack(alignment: .bottom) {
					APODMediaView(image: highResImage ?? lowResImage, imageURL: apodItem.imageURL, mediaType: apodItem.mediaType)
						.padding(.top)
					
					if showsProgressBar {
						ProgressView(value: [lowResProgress, highResProgress].filter { $0 < 1 }.max(), total: 1)
							.accentColor(lowResImage != nil ? .gray : .accentColor)
					}
				}
				
                BoldLabelText(boldLabel: apodItem.imageCreditLabel, text: apodItem.imageCredit)
                    .font(.caption)
                    .padding(.bottom)
                
				Text(apodItem.explanation)
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                
                Link("APOD Website", destination: URL(string: "https://apod.nasa.gov/apod/astropix.html")!)
                    .font(.callout)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
            }
            .padding()
        }
        .clipped()
		.onChange(of: apodItem) { newAPODItem in
			loadImages(from: newAPODItem, force: true)
		}
		.onChange(of: scenePhase) { phase in
			if phase == .active {
//				if apodItem.imageURL != nil && min(lowResProgress, highResProgress) < 1 && highResImage == nil {
//					loadImages(from: apodItem)
//				}
				for task in pausedTasks {
					guard let originalTask = tasks.first(where: { $0.0 == task.key }) else { return }
					let newTask = URLSession.shared.downloadTask(withResumeData: task.value) { (localURL, response, error) in
						guard let localURL = localURL else { return }
						guard let data = try? Data(contentsOf: localURL) else { return }
						let image = originalTask.3.absoluteString.hasSuffix(".gif") ? UIImage.gif(data: data) : UIImage(data: data)
						originalTask.1(image)
					}
					
					if originalTask.4 == .high {
						highResObservation = newTask.progress.observe(\.fractionCompleted) { (progress, _) in
							originalTask.5(progress.fractionCompleted)
						}
					} else {
						lowResObservation = newTask.progress.observe(\.fractionCompleted) { (progress, _) in
							originalTask.5(progress.fractionCompleted)
						}
					}
					newTask.resume()
					pausedTasks[task.key] = nil
					
				}
			} else if phase == .background {
				for taskEntry in tasks {
					taskEntry.0.cancel { data in
						guard let data = data else { return }
						pausedTasks[taskEntry.0] = data
					}
				}
			}
		}
		.onChange(of: lowResImage) { _ in
			print("SOEHNTOSEHNTO")
		}
    }
	
	
	func loadImages(from item: APODItem, force: Bool = false) {
		var highResURL = item.imageURL
		var lowResURL = item.lowResImageURL
		
		if item.mediaType == .video {
			(highResURL, lowResURL) = APODFetcher.getYouTubeThumbnailURLs(for: item.imageURL?.absoluteString ?? "")
		}
		
		highResImage = highResImage ?? item.image
		lowResImage = lowResImage ?? item.lowResImage
		
		if force {
			for task in pausedTasks.keys {
				task.cancel()
				pausedTasks[task] = nil
			}
			for taskEntry in tasks {
				taskEntry.0.cancel()
			}
			tasks = []
		}
		
		if highResImage == nil || force {
			loadImage(from: highResURL, completion: {
				highResImage = $0
				tasks.removeAll(where: { $0.4 == .high})
			}, observationKeyPath: \Self.highResObservation, progressObserved: { highResProgress = $0 }, quality: .high)
		}
		
		if lowResImage == nil || force {
			loadImage(from: lowResURL, completion: {
				lowResImage = $0
				tasks.removeAll(where: { $0.4 == .low})
			}, observationKeyPath: \Self.lowResObservation, progressObserved: { lowResProgress = $0 }, quality: .low)
		}
	}
	
	func loadImage(from url: URL?, completion: @escaping (UIImage?) -> Void, observationKeyPath: KeyPath<ContentView, NSKeyValueObservation?>, progressObserved: @escaping (Double) -> Void, quality: ImageQuality) {
		self[keyPath: \Self.highResObservation]?.invalidate()
		guard let url = url else { return }
		
//		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//			guard let data = data else { return }
//			let image = url.absoluteString.hasSuffix(".gif") ? UIImage.gif(data: data) : UIImage(data: data)
//			completion(image)
//		}
		
		let task = URLSession.shared.downloadTask(with: url) { (localURL, response, error) in
			guard let localURL = localURL else { return }
			guard let data = try? Data(contentsOf: localURL) else { return }
			let image = url.absoluteString.hasSuffix(".gif") ? UIImage.gif(data: data) : UIImage(data: data)
			completion(image)
		}
		
		self[keyPath: \Self.highResObservation] = task.progress.observe(\.fractionCompleted) { (progress, _) in
			progressObserved(progress.fractionCompleted)
		}
		
		tasks.append((task, completion, apodItem.date, url, quality, progressObserved))
		task.resume()
		
	}
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(apodItem: previewImageAPOD)
    }
}

