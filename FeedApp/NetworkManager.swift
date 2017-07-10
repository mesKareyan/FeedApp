//
//  NetworkManager.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit

enum RequestResult {
    case success(with: Any)
    case fail(with: Error)
}

enum InternalError: Error {
    case badResponse
}

class NetworkManager {
    
    static let shared = NetworkManager()
    private init () {}
    
    private struct Constants {
        private init() {}
        private static let apiKey = "1e955f6d-31eb-436c-aab7-d710fbbec527"
        private static let apiURLString = "https://content.guardianapis.com/search?api-key=" + apiKey
        static let apiURL = URL(string: apiURLString)!
    }
    
    typealias NetworkRequestCompletion = (RequestResult) -> ()
    
    func getNews(completion: @escaping NetworkRequestCompletion) {
        var request = URLRequest(url: Constants.apiURL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.fail(with: error!))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.fail(with: InternalError.badResponse))
                }
                return
            }
            let result = ApiRequestSerialization.resultFor(response: response, data: data)
            completion(result)
        }
        task.resume()
    }
    
    //MARK: - Images async donwload
    func downloadImage(at urlString: String, completion: @escaping (_ image: UIImage?) -> ()) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async() {
                completion(nil)
            }
            return
        }
        getDataFrom(url: url) { (data, response, error)  in
            guard let data = data, error == nil else {
                DispatchQueue.main.async() {
                    completion(nil)
                }
                return
            }
            let image =  UIImage(data: data)
            DispatchQueue.main.async() {
                completion(image)
            }
        }
    }
    
    private func getDataFrom(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
}

class ApiRequestSerialization {
    
    private init() {}
    
    fileprivate static func resultFor(response: URLResponse?,
                                      data: Data) -> RequestResult {
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            // check for http errors
            return .fail(with: InternalError.badResponse)
        }
        do {
            guard let jsonDict = try JSONSerialization.jsonObject(with: data,
                                                                  options: .allowFragments)
                as? [String : Any],
            let responseVal = jsonDict["response"] as? [String : Any],
            let results = responseVal["results"] as? [[String : Any]]
                else {
                    return .fail(with: InternalError.badResponse)
            }
            let news = results.map { reslultData in NewsFeedItem(with: reslultData) }
            return .success(with: news)
        }
        catch
        {
            return .fail(with: InternalError.badResponse)
        }
    }
}
