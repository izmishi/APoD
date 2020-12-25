//
//  APODFetcher.swift
//  APOD
//
//  Created by Izumu Mishima on 28/06/2020.
//

import Foundation
import SwiftUI

let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


func date(from string: String) -> Date {
	let stringComponents = string.components(separatedBy: " ")
	let date = Date()
	var dateComponents = DateComponents()
	
	dateComponents.year = Int(stringComponents[0]) ?? Calendar.current.component(.year, from: date)
	dateComponents.month =  1 + (months.firstIndex(of: stringComponents[1]) ?? (Calendar.current.component(.month, from: date) - 1))
	dateComponents.day = Int(stringComponents[2]) ?? Calendar.current.component(.day, from: date)
	
	// Create date from components
	return Calendar.current.date(from: dateComponents)!
}

func date(fromISO8601String string: String) -> Date {
	let formatter = ISO8601DateFormatter()
	formatter.formatOptions = .withFullDate
	return formatter.date(from: string) ?? Date()
}

public struct APODItem: Equatable {
	public enum MediaType: Equatable {
		case image
		case video
		case gif
		case unknown(String)
		
		init(from string: String) {
			switch string {
			case "image":
				self = .image
			case "video":
				self = .video
			case "gif":
				self = .gif
			default:
				self = .unknown(string)
			}
		}
	}
	
	public var title = ""
	public var date = Date()
	public var image: UIImage?
	public var lowResImage: UIImage?
	public var imageCreditLabel = ""
	public var imageCredit = ""
	public var explanation = ""
	public var mediaType: MediaType
	
	init(title: String = "Astronomy Picture of the Day", date: Date = Date(), image: UIImage? = nil, lowResImage: UIImage? = nil, imageCreditLabel: String = "", imageCredit: String = "", explanation: String = "", mediaType: MediaType = .unknown("")) {
		self.title = title
		self.date = date
		self.image = image
		self.lowResImage = lowResImage
		self.imageCreditLabel = imageCreditLabel
		self.imageCredit = imageCredit
		self.explanation = explanation
		self.mediaType = mediaType
	}
}

public class APODFetcher {
	static let apodURL = URL(string: "https://apod.nasa.gov/apod/astropix.html")!
	static let apodAPIURL = URL(string: "https://api.nasa.gov/planetary/apod?api_key=25b6nr3YANwX3OHWCs8jEYJ25Z3GKK8rjqCFVwXE")!
	
	public init() {
		
	}
	
	static let session = URLSession(configuration: .default)
	
	
	static func loadAPODFromAPI(completion: @escaping (APODItem?, Error?) -> Void) {
		session.dataTask(with: apodAPIURL) { (data, response, error) in
			guard let data = data else { return }

			guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] else { return }

			var imageCreditLabel = "Copyright"
			var imageCredit = ""
			var explanation = json["explanation"] ?? "No explanation"

			if let apodData = try? Data(contentsOf: apodURL) {
				if let apodHTML = String(data: apodData, encoding: .utf8) {
					(explanation, imageCreditLabel, imageCredit) = getExplanationAndCredits(from: apodHTML)
				}
			}


			let title = json["title"] ?? ""
			var mediaType = APODItem.MediaType(from: json["media_type"] ?? "Not Found")
			let apodURL = json["hdurl"] ?? json["url"] ?? ""
			let lowResURL = json["url"] ?? ""
			let copyright = imageCredit != "" ? imageCredit : (json["copyright"] ?? "Public Domain")
			var apodDate = Date()

			if let dateString = json["date"] {
				apodDate = date(fromISO8601String: dateString)
			}

			var apodImage: UIImage? = nil
			var lowResImage: UIImage? = nil
			
			if apodURL.hasSuffix(".gif") {
				mediaType = .gif
			}

			switch mediaType {
			case .image:
				if let url = URL(string: apodURL) {
					apodImage = getImage(for: url)
				}
				if let lowResURL = URL(string: lowResURL) {
					lowResImage = getImage(for: lowResURL)
				}
			case .gif:
				if let url = URL(string: apodURL) {
					apodImage = getGif(for: url)
				}
				if let lowResURL = URL(string: lowResURL) {
					lowResImage = getGif(for: lowResURL)
				}
			case .video:
				apodImage = getYouTubeThumbnail(for: apodURL)
			default:
				break
			}


			let apod = APODItem(title: title, date: apodDate, image: apodImage, lowResImage: lowResImage, imageCreditLabel: imageCreditLabel, imageCredit: copyright, explanation: explanation, mediaType: mediaType)

			completion(apod, error)
		}.resume()
	}
	
	static func getImage(for url: URL) -> UIImage? {
		do {
			let imageData = try Data(contentsOf: url)
			return UIImage(data: imageData)
		} catch {
			return nil
		}
	}
	
	static func getGif(for url: URL) -> UIImage? {
		if let gifData = try? Data(contentsOf: url) {
			return UIImage.gif(data: gifData)
		} else {
			return nil
		}
	}
	
	static func getYouTubeThumbnail(for urlString: String) -> UIImage? {
		guard let youtubeID = getYouTubeID(for: urlString) else {
			return nil
		}
		guard let url = URL(string: "https://img.youtube.com/vi/\(youtubeID)/hqdefault.jpg") else {
			return nil
		}
		
		return getImage(for: url)
	}
	
	static func getYouTubeID(for youtubeURLString: String) -> String? {
		guard let idPattern = try? NSRegularExpression(pattern: #"(?<=https:\/\/www\.youtube\.com\/embed\/)[^?]*"#) else {
			return nil
		}
		
		let range = NSRange(location: 0, length: youtubeURLString.count)
		
		let matchedNSRange = idPattern.rangeOfFirstMatch(in: youtubeURLString, range: range)
		
		guard let matchRange = Range(matchedNSRange, in: youtubeURLString) else {
			return nil
		}
		
		let id = youtubeURLString[matchRange]
		
		return String(id)
	}
	
	static func loadCurrentAPOD(completion: @escaping (APODItem?, Error?) -> Void) {
		session.dataTask(with: apodURL) { (data, response, error) in
			guard let data = data else { return }
			
			guard let apodHTML = String(data: data, encoding: .utf8) else {
				completion(nil, error)
				return
			}
			
			let apod = parseAPODHTML(apodHTML)
			
			completion(apod, error)
		}.resume()
	}
	
	static func getExplanationAndCredits(from html: String) -> (explanation: String, creditLabel: String, credit: String) {
		guard let imageCreditLabelPattern = try? NSRegularExpression(pattern: #"(?<=<b>).*?(?=<\/b>)"#) else {
			return ("", "", "")
		}
		
		var explanation = ""
		var imageCreditLabel = ""
		var imageCredit = ""
		
		for line in html.components(separatedBy: "<p>") {
			let paragraph = line.replacingOccurrences(of: #"\s"#, with: " ", options: .regularExpression)
			if paragraph.contains("<b> Explanation: </b>") {
				explanation = paragraph.replacingOccurrences(of: "<b> Explanation: </b>", with: "").replacingOccurrences(of: #"<.+?>"#, with: "", options: .regularExpression).replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespaces)
			} else if paragraph.contains("Credit") {
				for part in paragraph.components(separatedBy: "<center>") {
					if part.contains("Credit") {
						let matches = imageCreditLabelPattern.matches(in: part, range: NSRange(location: 0, length: part.count))
						for match in matches {
							let str = String(part.substringFromNSRange(match.range))
							if str.lowercased().contains("credit") {
								imageCreditLabel = str.replacingOccurrences(of: #"<.+?>"#, with: "", options: .regularExpression).replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespaces)
								break
							}
						}
						
						imageCredit = part.replacingOccurrences(of: #"<b>.*Credit.*<\/b>"#, with: "", options: .regularExpression).replacingOccurrences(of: #"<.+?>"#, with: "", options: .regularExpression).replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespaces)
					}
				}
			}
		}
		
		return (explanation, imageCreditLabel, imageCredit)
	}
	
	static func parseAPODHTML(_ html: String) -> APODItem {
		let boldPattern = try? NSRegularExpression(pattern: #"(?<=<b>).*(?=<\/b>)"#)
		
		let imageLinkPattern = try? NSRegularExpression(pattern: #"(?<=href=('|"))image\/.*\.(png|jpg|jpeg)(?=('|"))"#)
		let gifLinkPattern = try? NSRegularExpression(pattern: #"(?<=href=('|"))image\/.*\.gif(?=('|"))"#)
		let videoSRCPattern = try? NSRegularExpression(pattern: #"(?<=<iframe).*src="([^"]*)"#)
		
		let range = NSRange(location: 0, length: html.count)
		
		
		// The title
		let titleRange = boldPattern!.rangeOfFirstMatch(in: html, range: range)
		let title = html[Range(titleRange, in: html)!].trimmingCharacters(in: .whitespaces)
		
		
		// The image
		var image: UIImage? = nil
		var mediaType = APODItem.MediaType.unknown("")
		
		if let imageRange = imageLinkPattern?.rangeOfFirstMatch(in: html, range: range), imageRange.length > 0 {
			let imageLink = "https://apod.nasa.gov/apod/" + html[Range(imageRange, in: html)!].trimmingCharacters(in: .whitespaces)
			if let imageURL = URL(string: imageLink) {
				image = getImage(for: imageURL)
			}
			mediaType = .image
		} else if let gifRange = gifLinkPattern?.rangeOfFirstMatch(in: html, range: range), gifRange.length > 0 {
			let gifLink = "https://apod.nasa.gov/apod/" + html[Range(gifRange, in: html)!].trimmingCharacters(in: .whitespaces)
			if let gifURL = URL(string: gifLink) {
				image = getGif(for: gifURL)
			}
			mediaType = .gif
		} else if let videoMatch = videoSRCPattern?.firstMatch(in: html, range: range) {
			let videoSRC = String(html.substringFromNSRange(videoMatch.range(at: 1)))
			image = getYouTubeThumbnail(for: videoSRC)
			mediaType = .video
		}
		
		
		// Explanation and credits
		let (explanation, imageCreditLabel, imageCredit) = getExplanationAndCredits(from: html)
		
		
		// The date
		let dateString = html.components(separatedBy: "<p>")[2].replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: #"<br>.*"#, with: "", options: .regularExpression)
		
		let imageDate = date(from: dateString)
		
		return APODItem(title: title, date: imageDate, image: image, imageCreditLabel: imageCreditLabel, imageCredit: imageCredit, explanation: explanation, mediaType: mediaType)
	}
}
