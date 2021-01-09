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
extension Date {
	static func fromISO8601(string: String) -> Date? {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = .withFullDate
		return formatter.date(from: string)
	}
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
    public var imageURL: URL?
	public var lowResImageURL: URL?
	public var image: UIImage?
    public var lowResImage: UIImage?
    public var imageCreditLabel = ""
    public var imageCredit = ""
    public var explanation = ""
    public var mediaType: MediaType
    
	init(title: String = "Astronomy Picture of the Day", date: Date = Date(), imageURL: URL? = nil, lowResImageURL: URL? = nil, image: UIImage? = nil, lowResImage: UIImage? = nil, imageCreditLabel: String = "", imageCredit: String = "", explanation: String = "", mediaType: MediaType = .unknown("")) {
        self.title = title
        self.date = date
        self.imageURL = imageURL
		self.lowResImageURL = lowResImageURL
        self.image = image
        self.lowResImage = lowResImage
        self.imageCreditLabel = imageCreditLabel
        self.imageCredit = imageCredit
        self.explanation = explanation
        self.mediaType = mediaType
    }
}
//enum NetworkError: Error {
//	case badURL
//}

public class APODFetcher {
    static let apodURL = URL(string: "https://apod.nasa.gov/apod/astropix.html")!
    static let apodAPIURL = URL(string: "https://api.nasa.gov/planetary/apod?api_key=25b6nr3YANwX3OHWCs8jEYJ25Z3GKK8rjqCFVwXE")!
    
    public init() {
        
    }
    
	static let session = URLSession.shared
	
	enum FetchError: Error {
		case failedToLoad
	}
    
	static func loadAPODFromAPIWithoutImages(completion: @escaping (APODItem?, Error?) -> Void) {
		session.dataTask(with: apodAPIURL) { (data, response, error) in
			guard let data = data else { return }
			guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] else { return }
			
			// Get credits from the APOD website, because the API doesn't provide good credits
			var imageCredit: String?
			var imageCreditLabel = "Copyright"
			if let apodData = try? Data(contentsOf: apodURL), let apodHTML = String(data: apodData, encoding: .utf8) {
				(_, imageCreditLabel, imageCredit) = getExplanationAndCredits(from: apodHTML)
			}
			
			let title = json["title"] ?? ""
			let explanation = json["explanation"] ?? "No explanation"

			var mediaType = APODItem.MediaType(from: json["media_type"] ?? "Not Found")
			let apodURLString = json["hdurl"] ?? json["url"] ?? ""
			let lowResURLString = json["url"] ?? ""
			let copyright = imageCredit ?? json["copyright"] ?? "Public Domain"
			let apodDate = Date.fromISO8601(string: json["date"] ?? "") ?? Date()

			if apodURLString.hasSuffix(".gif") {
				mediaType = .gif
			}

			let partialAPOD = APODItem(title: title, date: apodDate, imageURL: URL(string: apodURLString), lowResImageURL: URL(string: lowResURLString), image: nil, lowResImage: nil, imageCreditLabel: imageCreditLabel, imageCredit: copyright, explanation: explanation, mediaType: mediaType)

			completion(partialAPOD, error)
		}
		.resume()
	}
    
    static func loadAPODFromAPIWithImages(completion: @escaping (APODItem?, Error?) -> Void) {
		loadAPODFromAPIWithoutImages { (apodItem, error) in
			guard let apodItem = apodItem else {
				completion(nil, FetchError.failedToLoad)
				return
			}
			
			var apodImage: UIImage? = nil
			var lowResImage: UIImage? = nil
			
			switch apodItem.mediaType {
			case .image:
				if let url = apodItem.imageURL {
					apodImage = getImage(for: url)
					lowResImage = apodImage
				}
				if let lowResURL = apodItem.lowResImageURL {
					lowResImage = getImage(for: lowResURL)
				}
			case .gif:
				if let url = apodItem.imageURL {
					apodImage = getGif(for: url)
					lowResImage = apodImage
				}
				if let lowResURL = apodItem.lowResImageURL {
					lowResImage = getGif(for: lowResURL)
				}
			case .video:
				(apodImage, lowResImage) = getYouTubeThumbnails(for: apodItem.imageURL?.absoluteString ?? "")
			default:
				break
			}
			
			
			var apod = apodItem
			
			apod.image = apodImage
			apod.lowResImage = lowResImage
			
			completion(apod, error)
		}
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
	
	static func getYouTubeThumbnailURLs(for videoURLString: String) -> (highRes: URL?, lowRes: URL?) {
		guard let youtubeID = getYouTubeID(for: videoURLString) else {
			return (nil, nil)
		}
		
		let lowResURL = URL(string: "https://img.youtube.com/vi/\(youtubeID)/hqdefault.jpg")
		let highResURL = URL(string: "https://img.youtube.com/vi/\(youtubeID)/maxresdefault.jpg")
		
		return (highResURL, lowResURL)
	}
    
    static func getYouTubeThumbnails(for urlString: String) -> (highRes: UIImage?, lowRes: UIImage?) {
        guard let youtubeID = getYouTubeID(for: urlString) else {
            return (nil, nil)
        }
        
        var lowResImage: UIImage? = nil
        var highResImage: UIImage? = nil
        
        if let lowResURL = URL(string: "https://img.youtube.com/vi/\(youtubeID)/hqdefault.jpg") {
            lowResImage = getImage(for: lowResURL)
        }
        if let highResURL = URL(string: "https://img.youtube.com/vi/\(youtubeID)/maxresdefault.jpg") {
            highResImage = getImage(for: highResURL)
        }
        
        return (highResImage, lowResImage)
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
    
}
