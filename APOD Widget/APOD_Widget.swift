//
//  APOD_Widget.swift
//  APOD Widget
//
//  Created by Izumu Mishima on 29/06/2020.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
	
	public typealias Entry = SimpleEntry
	
	func placeholder(in context: Context) -> SimpleEntry {
		return SimpleEntry(date: Date(), apodItem: APODItem())
	}
	
	func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
		
		if context.isPreview {
			// For the widget gallery
			let entry = SimpleEntry(date: Date(), apodItem: APODItem())
			completion(entry)
		} else {
			APODFetcher.loadCurrentAPOD { (apodItem, error) in
				let apod = apodItem ?? APODItem()
				let entry = SimpleEntry(date: Date(), apodItem: apod)
				
				completion(entry)
			}
		}
	}
	
	func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
		let oneDay = 86400.0
		APODFetcher.loadCurrentAPOD { (apodItem, error) in
			let apod = apodItem ?? APODItem()
			let entry = SimpleEntry(date: Date(), apodItem: apod)
			
			var calendar = Calendar.current
			calendar.timeZone = TimeZone(identifier: "America/Detroit")!
			
			let nextReloadDate = calendar.date(bySettingHour: 1, minute: 10, second: 0, of: Date().advanced(by: oneDay)) ?? Date().advanced(by: oneDay)
			
			
			let timeline = Timeline(entries: [entry], policy: .after(nextReloadDate))
			
			completion(timeline)
		}
	}
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
	public let apodItem: APODItem
}

struct PlaceholderView : View {
    var body: some View {
		PlaceholderImage(type: .image)
    }
}

struct APOD_WidgetEntryView : View {
    var entry: Provider.Entry
	
	@Environment(\.widgetFamily) var family
	
	var lightText: Bool {
		if let brightness = entry.apodItem.image?.averageBrightness {
			return brightness < 0.5
		}
		return true
	}

    var body: some View {
		
		if let apodImage = entry.apodItem.image {
			GeometryReader { geometry in
				ZStack(alignment: .leading) {
					
					Image(uiImage: apodImage)//.resizeSmallestDimensionDown(to: 1000) ?? apodImage)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: geometry.size.width, height: geometry.size.height)
					
					
					VStack(alignment: .leading) {
						
						if family != .systemSmall {
							// Image Title
							Text(entry.apodItem.title)
								.font(.headline)
							
							// Date
							if family == .systemLarge {
								Text(entry.apodItem.date, style: .date)
									.font(.subheadline)
							}
							
							// Image Credit
							Text(entry.apodItem.imageCredit)
								.font(.caption)
						}
						
						Spacer()
						
						if case APODItem.MediaType.video = entry.apodItem.mediaType {
							HStack {
							Spacer()
							Image(systemName: "video.fill")
								.font(.title2)
								.foregroundColor(lightText ? .white : .black)
								.shadow(color: lightText ? .black : .white, radius: 8)
								.opacity(0.5)
							}
						}
						
					}
					.foregroundColor(lightText ? .white : .black)
					.shadow(color: lightText ? .black : .white, radius: 8)
					.padding()
					
				}
			}
		} else {
			PlaceholderImage(type: .image)
		}
	}
}

@main
struct APOD_Widget: Widget {
    private let kind: String = "APOD_Widget"

    public var body: some WidgetConfiguration {
		
		StaticConfiguration(kind: kind, provider: Provider()) { entry in
            APOD_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Astronomy Picture of the Day")
        .description("Discover the cosmos!")
    }
}

struct APOD_Widget_Previews: PreviewProvider {
	
	static var previews: some View {
		Group {
			/*
			Group {
				APOD_WidgetEntryView(entry: SimpleEntry(date: Date(), apodItem: APODItem(image: UIImage(named: "TestImage"), imageCredit: "A Square")))
					.previewContext(WidgetPreviewContext(family: .systemSmall))
					.environment(\.colorScheme, .light)
				APOD_WidgetEntryView(entry: SimpleEntry(date: Date(), apodItem: APODItem(image: UIImage(named: "TestImage"), imageCredit: "A Rectangle")))
					.previewContext(WidgetPreviewContext(family: .systemMedium))
					.environment(\.colorScheme, .light)
				APOD_WidgetEntryView(entry: SimpleEntry(date: Date(), apodItem: APODItem(image: UIImage(named: "TestImage"), imageCredit: "A Square")))
					.previewContext(WidgetPreviewContext(family: .systemLarge))
					.environment(\.colorScheme, .light)
			}
			
			
			APOD_WidgetEntryView(entry: SimpleEntry(date: Date(), apodItem: APODItem(image: UIImage(named: "TestImage"), imageCredit: "A Square", mediaType: .video)))
				.previewContext(WidgetPreviewContext(family: .systemSmall))
				.environment(\.colorScheme, .light)
			
			APOD_WidgetEntryView(entry: SimpleEntry(date: Date(), apodItem: APODItem(image: UIImage(named: "TestImage2"), imageCredit: "A Square", mediaType: .video)))
				.previewContext(WidgetPreviewContext(family: .systemSmall))
				.environment(\.colorScheme, .light)
			*/
			
			/*
			// Layout
			APOD_WidgetEntryView(entry: SimpleEntry(date: Date(), apodItem: APODItem(title: "A Really, Really, Really Super Long Title To Test Layout", image: UIImage(named: "TestImage3"), imageCredit: "A Square", mediaType: .video)))
				.previewContext(WidgetPreviewContext(family: .systemSmall))
				.environment(\.colorScheme, .light)
			
			APOD_WidgetEntryView(entry: SimpleEntry(date: Date(), apodItem: APODItem(title: "A Really, Really, Really Super Long Title To Test Layout", image: UIImage(named: "TestImage3"), imageCredit: "A Rectangle", mediaType: .video)))
				.previewContext(WidgetPreviewContext(family: .systemMedium))
				.environment(\.colorScheme, .light)
			
			APOD_WidgetEntryView(entry: SimpleEntry(date: Date(), apodItem: APODItem(title: "A Really, Really, Really Super Long Title To Test Layout", image: UIImage(named: "TestImage3"), imageCredit: "A Square", mediaType: .video)))
				.previewContext(WidgetPreviewContext(family: .systemLarge))
				.environment(\.colorScheme, .light)
			*/
			
			Group {// Light and Dark
			APOD_WidgetEntryView(entry: SimpleEntry(date: Date(), apodItem: APODItem(image: UIImage(named: "TestImage"))))
				.previewContext(WidgetPreviewContext(family: .systemMedium))
				
			APOD_WidgetEntryView(entry: SimpleEntry(date: Date(), apodItem: APODItem(image: UIImage(named: "TestImage2"))))
				.previewContext(WidgetPreviewContext(family: .systemMedium))
				
			APOD_WidgetEntryView(entry: SimpleEntry(date: Date(), apodItem: APODItem(image: UIImage(named: "TestImage3"))))
				.previewContext(WidgetPreviewContext(family: .systemMedium))
				
			APOD_WidgetEntryView(entry: SimpleEntry(date: Date(), apodItem: APODItem(image: UIImage(named: "TestImage4"))))
				.previewContext(WidgetPreviewContext(family: .systemMedium))
			}
		
			
			// Placeholder
			PlaceholderView()
				.previewContext(WidgetPreviewContext(family: .systemSmall))
				.environment(\.colorScheme, .dark)
			
			PlaceholderView()
				.previewContext(WidgetPreviewContext(family: .systemSmall))
				.environment(\.colorScheme, .light)
		}
	}
}
