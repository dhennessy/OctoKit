//
//  CommentTests.swift
//  OctoKit
//
//  Created by Denis Hennessy on 19/04/2017.
//  Copyright © 2017 Peer Assembly Ltd. All rights reserved.
//

import XCTest
import OctoKit

class CommentTests: XCTestCase {
    
    func testGetComment() {
        let session = OctoKitURLTestSession(expectedURL: "https://api.github.com/repos/octocat/Hello-World/issues/comments/12345", expectedHTTPMethod: "GET", jsonFile: "comment", statusCode: 200)
        let task = Octokit().comment(session, owner: "octocat", repository: "Hello-World", id: 12345) { response in
            switch response {
            case .success(let comment):
                XCTAssertEqual(comment.id, 12345)
            case .failure:
                XCTAssert(false, "should not get an error")
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }
    
    func testGetComments() {
        let session = OctoKitURLTestSession(expectedURL: "https://api.github.com/repos/octocat/Hello-World/issues/comments?page=1&per_page=100", expectedHTTPMethod: "GET", jsonFile: "comments", statusCode: 200)
        let task = Octokit().comments(session, owner: "octocat", repository: "Hello-World") { response in
            switch response {
            case .success(let comments):
                XCTAssertEqual(comments.count, 3)
            case .failure:
                XCTAssert(false, "should not get an error")
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }
    
    func testGetIssueComments() {
        let session = OctoKitURLTestSession(expectedURL: "https://api.github.com/repos/octocat/Hello-World/issues/12345/comments", expectedHTTPMethod: "GET", jsonFile: "comments", statusCode: 200)
        let task = Octokit().issueComments(session, owner: "octocat", repository: "Hello-World", number: "12345") { response in
            switch response {
            case .success(let comments):
                XCTAssertEqual(comments.count, 3)
            case .failure:
                XCTAssert(false, "should not get an error")
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }
    
    func testCreateComment() {
        let session = OctoKitURLTestSession(expectedURL: "https://api.github.com/repos/octocat/Hello-World/issues/12345/comments", expectedHTTPMethod: "POST", jsonFile: "comment", statusCode: 200)
        let task = Octokit().postComment(session, owner: "octocat", repository: "Hello-World", number: "12345", body: "Bug or Feature?") { response in
            switch response {
            case .success(let comment):
                XCTAssertEqual(comment.id, 12345)
            case .failure:
                XCTAssert(false, "should not get an error")
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }
    
    func testParsingComment() {
        let subject = IssueComment(Helper.JSONFromFile("comment") as! [String: AnyObject])
        XCTAssertEqual(subject.body, "I think I heard something about this in early Mavericks betas. Looks like you're not running a beta though...\n")
        XCTAssertEqual(subject.createdAt, Helper.rfc3339Date("2013-11-22T19:33:04Z"))
        XCTAssertEqual(subject.htmlURL, URL(string: "https://github.com/dhennessy/BugHub/issues/13#issuecomment-29102052"))
        XCTAssertEqual(subject.id, 12345)
        XCTAssertEqual(subject.issueURL, URL(string: "https://api.github.com/repos/dhennessy/BugHub/issues/13"))
        XCTAssertEqual(subject.updatedAt, Helper.rfc3339Date("2013-11-22T19:35:04Z"))
        XCTAssertEqual(subject.url, URL(string: "https://api.github.com/repos/dhennessy/BugHub/issues/comments/29102052"))
        XCTAssertEqual(subject.user?.login, "Me1000")
        XCTAssertEqual(subject.user?.id, 90050)
    }

}
