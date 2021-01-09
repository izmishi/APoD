//
//  Preview Data.swift
//  APOD
//
//  Created by Izumu Mishima on 08/01/2021.
//

import UIKit

let previewImage = UIImage(named: "TestImage")
let previewImageAPOD = APODItem(title: "Astronomy Picture of the Day Preview Content", date: Date(), imageURL: nil, image: previewImage, lowResImage: previewImage, imageCreditLabel: "Test Credit Label", imageCredit: "Some Person", explanation: "This is a preview image for Astronomy Picture of the Day. As you can see, it is a picture", mediaType: .image)
