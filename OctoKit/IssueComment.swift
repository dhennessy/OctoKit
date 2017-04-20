//
//  IssueComment.swift
//  OctoKit
//
//  Created by Denis Hennessy on 19/04/2017.
//  Copyright © 2017 Peer Assembly Ltd. All rights reserved.
//

import Foundation
import RequestKit

// Called 'IssueComment' to avoid a conflict with Comment in CarbonCore
@objc open class IssueComment: NSObject {
    open var body: String?
    open var createdAt: Date?
    open var htmlURL: URL?
    open var id: Int
    open var issueURL: URL?
    open var updatedAt: Date?
    open var url: URL?
    open var user: User?

    public init(_ json: [String: AnyObject]) {
        if let id = json["id"] as? Int {
            self.id = id
            
            body = json["body"] as? String
            createdAt = Time.rfc3339Date(json["created_at"] as? String)
            if let urlString = json["html_url"] as? String, let url = URL(string: urlString) {
                htmlURL = url
            }
            if let urlString = json["issue_url"] as? String, let url = URL(string: urlString) {
                issueURL = url
            }
            updatedAt = Time.rfc3339Date(json["updated_at"] as? String)
            if let urlString = json["url"] as? String, let url = URL(string: urlString) {
                self.url = url
            }
            user = User(json["user"] as? [String: AnyObject] ?? [:])
        } else {
            id = -1
        }
    }
}

// MARK: request

public extension Octokit {

    /**
     Fetches a comment in a repository
     - parameter session: RequestKitURLSession, defaults to URLSession.sharedSession()
     - parameter owner: The user or organization that owns the repository.
     - parameter repository: The name of the repository.
     - parameter id: The id of the comment.
     - parameter completion: Callback for the outcome of the fetch.
     */
    public func comment(_ session: RequestKitURLSession = URLSession.shared, owner: String, repository: String, id: Int, completion: @escaping (_ response: Response<IssueComment>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = CommentRouter.readComment(configuration, owner, repository, id)
        return router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let json = json {
                    let comment = IssueComment(json)
                    completion(Response.success(comment))
                }
            }
        }
    }
    
    /**
     Fetches all comments in a repository
     - parameter session: RequestKitURLSession, defaults to URLSession.sharedSession()
     - parameter owner: The user or organization that owns the repository.
     - parameter repository: The name of the repository.
     - parameter page: Current page for comment pagination. `1` by default.
     - parameter perPage: Number of comments per page. `100` by default.
     - parameter completion: Callback for the outcome of the fetch.
     */
    public func comments(_ session: RequestKitURLSession = URLSession.shared, owner: String, repository: String, page: String = "1", perPage: String = "100", completion: @escaping (_ response: Response<[IssueComment]>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = CommentRouter.readComments(configuration, owner, repository, page, perPage)
        return router.loadJSON(session, expectedResultType: [[String: AnyObject]].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let json = json {
                    let parsedComments = json.map { IssueComment($0) }
                    completion(Response.success(parsedComments))
                }
            }
        }
    }
    
    /**
     Fetches all comments for an issue
     - parameter session: RequestKitURLSession, defaults to URLSession.sharedSession()
     - parameter owner: The user or organization that owns the repository.
     - parameter repository: The name of the repository.
     - parameter number: The number of the issue.
     - parameter completion: Callback for the outcome of the fetch.
     */
    public func issueComments(_ session: RequestKitURLSession = URLSession.shared, owner: String, repository: String, number: String, completion: @escaping (_ response: Response<[IssueComment]>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = CommentRouter.readIssueComments(configuration, owner, repository, number)
        return router.loadJSON(session, expectedResultType: [[String: AnyObject]].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let json = json {
                    let parsedComments = json.map { IssueComment($0) }
                    completion(Response.success(parsedComments))
                }
            }
        }
    }
    
    /**
     Creates an comment for an issue.
     - parameter session: RequestKitURLSession, defaults to URLSession.sharedSession()
     - parameter owner: The user or organization that owns the repository.
     - parameter repository: The name of the repository.
     - parameter number: The number of the issue.
     - parameter body: The body text of the comment in GitHub-flavored Markdown format.
     - parameter completion: Callback for the comment that is created.
     */
    public func postComment(_ session: RequestKitURLSession = URLSession.shared, owner: String, repository: String, number: String, body: String, completion: @escaping (_ response: Response<IssueComment>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = CommentRouter.postComment(configuration, owner, repository, number, body)
        return router.postJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let json = json {
                    let comment = IssueComment(json)
                    completion(Response.success(comment))
                }
            }
        }
    }
    
    /**
     Edits a comment in a repository.
     - parameter session: RequestKitURLSession, defaults to URLSession.sharedSession()
     - parameter owner: The user or organization that owns the repository.
     - parameter repository: The name of the repository.
     - parameter id: The id of the comment.
     - parameter body: The body text of the comment in GitHub-flavored Markdown format.
     - parameter completion: Callback for the comment that is created.
     */
    public func patchComment(_ session: RequestKitURLSession = URLSession.shared, owner: String, repository: String, id: Int, body: String, completion: @escaping (_ response: Response<IssueComment>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = CommentRouter.patchComment(configuration, owner, repository, id, body)
        return router.postJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let json = json {
                    let comment = IssueComment(json)
                    completion(Response.success(comment))
                }
            }
        }
    }
    
    /**
     Deletes a comment in a repository.
     - parameter session: RequestKitURLSession, defaults to URLSession.sharedSession()
     - parameter owner: The user or organization that owns the repository.
     - parameter repository: The name of the repository.
     - parameter id: The id of the comment.
     - parameter completion: Callback for the issue that is created.
     */
    public func patchComment(_ session: RequestKitURLSession = URLSession.shared, owner: String, repository: String, id: Int, completion: @escaping (_ response: Error?) -> Void) -> URLSessionDataTaskProtocol? {
        let router = CommentRouter.deleteComment(configuration, owner, repository, id)
        return router.postJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
}

// MARK: Router

enum CommentRouter: JSONPostRouter {
    case deleteComment(Configuration, String, String, Int)
    case readComment(Configuration, String, String, Int)
    case readComments(Configuration, String, String, String, String)
    case readIssueComments(Configuration, String, String, String)
    case patchComment(Configuration, String, String, Int, String)
    case postComment(Configuration, String, String, String, String)

    var method: HTTPMethod {
        switch self {
        case .deleteComment:
            // TODO: This should really be DELETE but RequestKit doesn't support it
            return .POST
        case .readComment, .readComments, .readIssueComments:
            return .GET
        case .patchComment:
            // TODO: This should really be PATCH but RequestKit doesn't support it
            return .POST
        case .postComment:
            return .POST
        }
    }
    
    var encoding: HTTPEncoding {
        switch self {
        case .deleteComment, .readComment, .readComments, .readIssueComments:
            return .url
        case .patchComment, .postComment:
            return .json
        }
    }
    
    var configuration: Configuration {
        switch self {
        case .deleteComment(let config, _, _, _): return config
        case .readComment(let config, _, _, _): return config
        case .readComments(let config, _, _, _, _): return config
        case .readIssueComments(let config, _, _, _): return config
        case .patchComment(let config, _, _, _, _): return config
        case .postComment(let config, _, _, _, _): return config
        }
    }
    
    var params: [String: Any] {
        switch self {
        case .deleteComment, .readComment, .readIssueComments:
            return [:]
        case .readComments(_, _, _, let page, let perPage):
            return ["per_page": perPage, "page": page]
        case .patchComment(_, _, _, _, let body):
            return ["body": body]
        case .postComment(_, _, _, _, let body):
            return ["body": body]
        }
    }
    
    var path: String {
        switch self {
        case .deleteComment(_, let owner, let repository, let id):
            return "repos/\(owner)/\(repository)/issues/comments/\(id)"
        case .readComment(_, let owner, let repository, let id):
            return "repos/\(owner)/\(repository)/issues/comments/\(id)"
        case .readComments(_, let owner, let repository, _, _):
            return "repos/\(owner)/\(repository)/comments"
        case .readIssueComments(_, let owner, let repository, let number):
            return "repos/\(owner)/\(repository)/issues/\(number)/comments"
        case .patchComment(_, let owner, let repository, let id, _):
            return "repos/\(owner)/\(repository)/issues/comments/\(id)"
        case .postComment(_, let owner, let repository, let number, _):
            return "repos/\(owner)/\(repository)/issues/\(number)/comments"
        }
    }
}
