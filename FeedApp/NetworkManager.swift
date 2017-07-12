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

extension URL {
    
    init?(string: String, queryParameters: [String : String]) {
        self.init(string: string)
        //params
        guard var urlComponents = URLComponents(string: string) else {
            return nil
        }
        urlComponents.queryItems = queryParameters.map {
            component in URLQueryItem(name: component.key, value: component.value)
        }
        if let url = urlComponents.url {
            self = url
        }
    }
    
}

class NetworkManager {
    
    static let shared = NetworkManager()
    private init () {}
    
    private struct API {
        
        private init() {}
        
        private static let apiKey = "1e955f6d-31eb-436c-aab7-d710fbbec527"
        private static let base = "https://content.guardianapis.com/search"

        static let  urlForNewestNews =
            URL(string: base,
                queryParameters: [
                    "api-key"   : apiKey,
                    "page-size" : String(Constants.newsPageCount),
                    "show-fields" : "thumbnail"
                ])!
        
        static func urlFor(page: Int) -> URL {
            let urlForNews =
                URL(string: base,
                    queryParameters: [
                        "api-key"     : apiKey,
                        "page"        : String(page),
                        "page-size"   : String(Constants.newsPageCount),
                        "show-fields" : "thumbnail"
                ])!
            return urlForNews
        }
        
        static func urlForSingleNews(url: String) -> URL {
            let urlForNews =
                URL(string: url,
                    queryParameters: [
                        "api-key"     : apiKey,
                        "show-fields" : "body"
                    ])!
            return urlForNews
        }
        
    }
    
    typealias NetworkRequestCompletion = (RequestResult) -> ()
    
    func getNewestNews(completion: @escaping NetworkRequestCompletion) {
        var request = URLRequest(url: API.urlForNewestNews)
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
    
    func getNews(atPage page: Int, completion: @escaping NetworkRequestCompletion) {
        var request = URLRequest(url: API.urlFor(page: page))
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
    
    //Single item
    
    func getBodyFor(newsItem: NewsFeedEntity,
                     completion: @escaping NetworkRequestCompletion) {
        var request = URLRequest(url: API.urlForSingleNews(url: newsItem.newsItem!.apiURL!))
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    //fail
                    completion(.fail(with: error!))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    //fail
                    completion(.fail(with: InternalError.badResponse))
                }
                return
            }
            let result = ApiRequestSerialization.resultBodyFrom(response: response, data: data)
            completion(result)
        }
        task.resume()
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
    
    fileprivate static func resultBodyFrom(response: URLResponse?,
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
                let results = responseVal["content"] as? [String : Any],
                let fields  = results["fields"] as? [String: Any],
                let body    = fields["body"] as? String
                else {
                     return .fail(with: InternalError.badResponse)
            }
            return .success(with: body)
        }
        catch
        {
            return .fail(with: InternalError.badResponse)
        }
    }
    
}
