//
//  Subreddit.swift
//  readder
//
//  Created by Fran González on 17/12/17.
//  Copyright © 2017 Fran González. All rights reserved.
//

import RealmSwift

/**
 Representation of a subreddit for the `Realm` database.
*/
class Subreddit : Object {
    // Name of the subreddit that will be loaded. Example: nosleep.
    @objc dynamic var name: String = ""
    
    // Max time of the posts to be fetched. Since we're using /top as the way of getting
    // the posts, this indicates whether the post should be from hour, day, week...
    @objc dynamic var time: String = ""
}
