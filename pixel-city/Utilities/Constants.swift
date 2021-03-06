//
//  Constants.swift
//  pixel-city
//
//  Created by Abdelhamid Naeem on 11/3/18.
//  Copyright © 2018 Abdelhamid Naeem. All rights reserved.
//

import Foundation

let  apikey = "6d21d93372ceb6c1e6e42cc4d2379875"

func flickerUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, numberOfPhotos number: Int) -> String {
    let url =  "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apikey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"

    print(url)
    return url
}
