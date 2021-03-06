//
//  RedditApi.swift
//  readder
//
//  Created by Fran González on 17/12/17.
//  Copyright © 2017 Fran González. All rights reserved.
//

import RxSwift
import RxAlamofire
import SwiftyJSON

/**
 Static class that provides methods to interact with the Reddit API.
*/
class RedditApi {
    // MARK: Stuff we need to keep track of.
    private static var accesToken: String?
    
    // MARK: General headers.
    static let headers = [
        "User-Agent": "spaceisstrange.io.readder:v1.0"
    ]
    
    // MARK: Time values.
    enum Time: String {
        case day = "day"
        case week = "week"
        case month = "month"
        case year = "year"
        case allTime = "all"
    }
    
    // MARK: Authentication functions.
    
    /**
     Obtains the access token needed to interact with the Reddit API.
     
     - returns: An observable wrapping the `HTTPURLResponse`.
    */
    static func getAccessToken() -> Observable<HTTPURLResponse> {
        let authHeaders = basicAuthHeaders(of: headers)
        
        return RxAlamofire.requestJSON(.post,
                                       ACCESS_TOKEN_URL,
                                       parameters: ACCESS_TOKEN_PARAMETERS,
                                       headers: authHeaders)
        .map({ (response, data) in
            let json = JSON(data)
            
            // Save the token for later use.
            accesToken = json["access_token"].string
            
            return response
        })
        .observeOn(MainScheduler.instance)
    }
    
    // MARK: Subreddit functions.
    
    /**
     Obtains stories from a subreddit.
     
     - parameter from: Subreddit from where to obtain the stories.
     - parameter time: Time of the posts to filter (day, week, month...)
     - parameter max: Maximum number of posts to get.
     
     - returns: Observable wrapping an array of `Story`.
    */
    static func getStories(from subreddit: String, time: Time, max: Int = 20) -> Observable<[Story]> {
        let bearerHeaders = bearerAuthHeaders(of: headers, accessToken: accesToken!)
        
        return RxAlamofire.requestJSON(.get,
                                       subredditEndpoint(subreddit, time: time.rawValue, limit: max),
                                       headers: bearerHeaders)
        .map({ (response, data) in
            let json = JSON(data)
            var stories: [Story] = []
            
            // Iterate through all the posts turning them into stories.
            for (_, post):(String, JSON) in json["data"]["children"] {
                let postData = post["data"]
                let title = postData["title"].string
                let content = postData["selftext"].string
                
                let story = Story(title: title!, content: content!)
                stories.append(story)
            }
            
            return stories
        })
        .observeOn(MainScheduler.instance)
    }
}
