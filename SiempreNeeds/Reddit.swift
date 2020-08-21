//
//  Reddit.swift
//  SiempreNeeds
//


import Foundation
import UIKit

class Reddit {
    static let shared = Reddit()
    
    let kRedditAccessTokenEndpoint = "https://www.reddit.com/api/v1/access_token"
    let kRedditInstalledClientGrantEndpoint = "https://oauth.reddit.com/grants/installed_client"
    let kRedditAwwEndpoint =
        "https://oauth.reddit.com/r/aww/top?limit=25&t=hour"
    let kRedditOAuth2ClientId = "YOURTOKENHERE"
   
    private init() {}
    
    func getAccessToken(_ completion: @escaping (String) -> Void) {
        let basicAuthValue = "\(kRedditOAuth2ClientId):".data(using: .utf8)!.base64EncodedString()
        print(basicAuthValue)

        var request = URLRequest(url: URL(string: kRedditAccessTokenEndpoint)!)
        request.httpMethod = "POST"
        request.httpBody = "grant_type=\(kRedditInstalledClientGrantEndpoint)&device_id=\(UUID().uuidString)".data(using: .utf8)
        request.setValue("Basic \(basicAuthValue)", forHTTPHeaderField: "Authorization")
        request.setValue("SiempreNeeds", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { (data, res, err) in
            if let err = err {
                Log(err.localizedDescription)
                return
            }
            guard let object = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] else {
                Log("invalid JSON from reddit")
                return
            }
            guard let token = object["access_token"] as? String else {
                if (object.keys.contains("error")) {
                    Log("Reddit error: \(object["message"] as? String ?? "nil")")
                } else {
                    Log("invalid JSON from reddit")
                }
                return
            }
            completion(token)
        }
        task.resume()
    }
    
    func getAww(_ completion: @escaping (UIImage) -> Void) {
        getAccessToken() { token in
            var request = URLRequest(url: URL(string: self.kRedditAwwEndpoint)!)
            request.httpMethod = "GET"
            request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("SiempreNeeds", forHTTPHeaderField: "User-Agent")
            let task = URLSession.shared.dataTask(with: request) { (data, res, err) in
                if let err = err {
                    Log(err.localizedDescription)
                    return
                }
                guard let resp = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] else {
                    Log("invalid JSON from reddit")
                    return
                }
                guard let resp_data = resp["data"] as? [String: Any],
                      let children = resp_data["children"] as? [Any]
                else {
                    if (resp.keys.contains("error")) {
                        Log("Reddit error: \(resp["message"] as? String ?? "nil")")
                    } else {
                        Log("Error parsing Reddit JSON")
                    }
                    return
                }
                let urls = children.map() {(post) -> String in
                    guard let post = post as? [String: Any],
                          let post_data = post["data"] as? [String: Any],
                          let url = post_data["url"] as? String else {
                        Log("Error parsing Reddit JSON")
                        return ""
                    }
                    return url
                }.filter() {(url_str) in
                   return url_str.hasSuffix(".jpg") ||
                          url_str.hasSuffix(".png") ||
                          url_str.hasSuffix(".gif")
                }
                var subtasks : [URLSessionDataTask] = []
                for url_str in urls {
                    guard let url = URL(string: url_str) else {
                        continue
                    }
                    let subtask = URLSession.shared.dataTask(with: url) { (data, res, err) in
                        if let err = err {
                            Log(err.localizedDescription)
                            return
                        }
                        guard let data = data,
                              let image = UIImage(data: data)
                        else {
                            return
                        }
                        completion(image)
                    }
                    subtasks.append(subtask)
                    subtask.resume()
                }
            }
            task.resume()
        }
    }
}
