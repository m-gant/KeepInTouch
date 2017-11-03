//
//  SongDownloader.swift
//  Tunes
//
//  Created by Mitchell Gant on 10/31/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import Foundation

struct SongsDownloader {
    
    
    struct SongResponse: Codable {
        let resultCount: Int
        let results : [Song]
    }
    
    
    static func downloadSongs(searchTerm: String, completion: @escaping([Song]) -> Void) {
        let url = URL(string: "https://itunes.apple.com/search?term=\(searchTerm)&entity=song")!
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print(error?.localizedDescription ?? "Error making request")
                completion([])
                return
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers), let typedJson = jsonObject as? [String: Any], let result = typedJson["results"] as? [[String:Any]] else {
                print("Failed json parsing")
                completion([])
                return
            }
            
            let jsonDecoder = JSONDecoder()
            if let songResponse = try? jsonDecoder.decode(SongResponse.self, from: data) {
                completion(songResponse.results)
            }
        }
        
        task.resume()
    }
}

