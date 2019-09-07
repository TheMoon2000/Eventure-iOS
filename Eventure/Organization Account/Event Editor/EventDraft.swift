//
//  EventDraft.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventDraft: UIPageViewController {
    
    var orgEventView: OrgEventViewController?
    var detailPage: EventDetailPage?
    
    static let backgroundColor: UIColor = .init(white: 0.94, alpha: 1)
    
    var edited = false
    
    var isEditingExistingEvent = false
    var currentPage = -1 {
        didSet {
            navigationItem.title = [
                "1. What's Happening?",
                "2. When and Where?",
                "3. Other Information"
            ][currentPage]
            
            let percentage = Float(currentPage + 1) / Float(pages.count)
            progressIndicator?.setProgress(percentage, animated: true)
            
            if currentPage + 1 < pages.count {
                navigationItem.rightBarButtonItem?.title = "Next"
            } else {
                navigationItem.rightBarButtonItem?.title = "Finish"
            }
        }
    }
    var draft: Event!
    var pages = [UIViewController]()
    
    private var progressIndicator: UIProgressView!
    
    var saveHandler: ((UIAlertAction) -> Void)!
    
    /// Records the progress of the user's current swipe gesture. Negative values indicate a backward swipe.
    var transitionProgress: CGFloat = 0.0 {
        didSet {
            // Update bar percentage
            let barPercentage = (Float(currentPage + 1) + Float(transitionProgress)) / Float(pages.count)
            progressIndicator.setProgress(barPercentage, animated: true)
        }
    }
    
    required init(event: Event, detailPage: EventDetailPage? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        self.draft = event
        self.detailPage = detailPage
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = EventDraft.backgroundColor
        dataSource = self
        
        // Prepare for transition progress detection
        view.subviews.forEach { ($0 as? UIScrollView)?.delegate = self }
        
        navigationItem.leftBarButtonItem = .init(title: "Close", style: .plain, target: self, action: #selector(exitEditor))
        navigationItem.rightBarButtonItem = .init(title: "Next", style: .done, target: self, action: #selector(flipPage(_:)))
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        // Set up pages

        let descPage = DraftDescriptionPage()
        descPage.draftPage = self
        pages.append(descPage)
        
        let tlPage = DraftTimeLocationPage()
        tlPage.draftPage = self
        pages.append(tlPage)
        
        let otherPage = DraftOtherInfoPage()
        otherPage.draftPage = self
        pages.append(otherPage)

        
        // Set up progress indicator in the navigation bar.
        progressIndicator = {
            let bar = UIProgressView(progressViewStyle: .bar)
            bar.trackTintColor = .init(white: 0.9, alpha: 1)
            bar.progressTintColor = MAIN_TINT
            bar.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(bar)
            bar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            bar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            
            return bar
        }()
        
        currentPage = 0
        setViewControllers([descPage], direction: .forward, animated: false, completion: nil)
        
        let orgID = Organization.current!.id
        
        saveHandler = { action in
            var drafts: Set<Event> = self.orgEventView?.allDrafts ?? ( Event.readFromFile(path: DRAFTS_PATH.path)[orgID] ?? [])
            
            drafts.remove(self.draft)
            drafts.insert(self.draft)
            
            print("Current draft titles: ", drafts.map { $0.title })
            
            if Event.writeToFile(orgID: orgID, events: drafts, path: DRAFTS_PATH.path) {
                self.detailPage?.event = self.draft
                self.orgEventView?.allDrafts = drafts
                self.orgEventView?.eventCatalog.reloadData()
                self.dismiss(animated: true, completion: nil)
            } else {
                let warning = UIAlertController(title: "Save Error", message: "No write permission.", preferredStyle: .alert)
                warning.addAction(.init(title: "Dismiss", style: .cancel, handler: nil))
                self.present(warning, animated: true, completion: nil)
            }
        }
    }
    
    @objc func exitEditor() {
        
        self.view.endEditing(true)
        
        guard edited else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Save changes?"
        
        if !isEditingExistingEvent {
            alert.message = "You can save the event as a draft and come back later, or discard it."
            alert.addAction(.init(title: "Save as Draft", style: .default, handler: saveHandler))
        } else if draft.published {
            alert.message = "You have made changes to a published event."
            alert.addAction(.init(title: "Save and Re-publish", style: .default, handler: { action in
                self.publishEvent()
            }))
        } else {
            alert.message = "You have made changes to an existing draft."
            alert.addAction(.init(title: "Update Draft", style: .default, handler: saveHandler))
        }
        
        alert.addAction(.init(title: "Discard Changes", style: .destructive, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func flipPage(_ sender: UIBarButtonItem) {
        if sender.title == "Next" {
            if currentPage + 1 < pages.count {
                setViewControllers([pages[currentPage + 1]], direction: .forward, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Event Completed", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))

            if !draft.published && !isEditingExistingEvent {
                alert.message = "You have finished composing your new event. Would you like to publish it now?"
                alert.addAction(.init(title: "Save to Drafts", style: .default, handler: saveHandler))
                alert.addAction(.init(title: "Publish", style: .default, handler: { action in
                    self.publishEvent()
                }))
            } else if !draft.published {
                alert.message = "You have modified a draft event. Would you like to save your changes or publish this event right away?"
                alert.addAction(.init(title: "Save and Close", style: .default, handler: saveHandler))
                alert.addAction(.init(title: "Publish", style: .default, handler: { action in
                    self.publishEvent()
                }))
            } else {
                alert.message = "You have modified a published event. Would you like to publish your changes now or save a new local copy of it?"
                alert.addAction(.init(title: "Save as New Draft", style: .default, handler: { action in
                    self.draft.renewUUID() // The event now has its own UUID.
                    self.draft.published = false // Duplicate copy is not published.
                    self.saveHandler(action)
                }))
                alert.addAction(.init(title: "Re-publish", style: .default, handler: { action in
                    self.publishEvent()
                }))
            }
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func publishEvent() {
        
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        
        let doneButton = navigationItem.rightBarButtonItem!
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        
        let warning = UIAlertController(title: "Unable to publish event", message: nil, preferredStyle: .alert)
        warning.addAction(.init(title: "OK", style: .cancel, handler: nil))
        
        // Perform a series of checks to make sure that the event is valid
        guard !draft.title.isEmpty else {
            warning.message = "Event title should not be blank!"
            present(warning, animated: true) {
                self.navigationItem.rightBarButtonItem = doneButton
            }
            return
        }
        
        guard draft.startTime != nil else {
            warning.message = "Event start time should not be blank!"
            present(warning, animated: true) {
                self.navigationItem.rightBarButtonItem = doneButton
            }
            return
        }
        
        guard draft.endTime != nil else {
            warning.message = "Event end time should not be blank!"
            present(warning, animated: true) {
                self.navigationItem.rightBarButtonItem = doneButton
            }
            return
        }
        
        guard !draft.tags.isEmpty && draft.tags.count <= 3 else {
            warning.message = "You must pick between 1 ~ 3 tags!"
            present(warning, animated: true) {
                self.navigationItem.rightBarButtonItem = doneButton
            }
            return
        }
        
        let url = URL(string: API_BASE_URL + "events/CreateEvent")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "uuid": draft.uuid,
            "orgId": Organization.current!.id,
            "title": draft.title,
            "description": draft.eventDescription,
            "location": draft.location,
            "startTime": DATE_FORMATTER.string(from: draft.startTime!),
            "endTime": DATE_FORMATTER.string(from: draft.endTime!),
            "public": "1",
            "tags": draft.tags.description,
            "capacity": String(draft.capacity)
        ]
        
        var fileData = [String : Data]()
        fileData["cover"] = draft.eventVisual?.fixedOrientation().sizeDownData(maxWidth: 500)
        
        request.addMultipartBody(parameters: parameters, files: fileData)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem = doneButton
                }
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8)!
            switch msg {
            case INTERNAL_ERROR:
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem = doneButton
                    serverMaintenanceError(vc: self)
                }
            case "success":
                self.draft.published = true
                self.draft.lastModified = Date()
                EventDraft.removeDraft(uuid: self.draft.uuid) { remaining in

                    var published: Set<Event> = self.orgEventView?.allEvents ?? []
                    published.remove(self.draft)
                    published.insert(self.draft)
                    
                    DispatchQueue.main.async {
                        self.detailPage?.event = self.draft
                        self.orgEventView?.allEvents = published
                        self.orgEventView?.allDrafts = remaining
                        self.orgEventView?.eventCatalog.reloadSections([0])
                        self.navigationItem.rightBarButtonItem = doneButton
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
            default:
                warning.message = msg
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem = doneButton
                    self.present(warning, animated: true, completion: nil)
                }
            }
        }
        
        task.resume()
    }
    
    static func removeDraft(uuid: String, handler: ((Set<Event>) -> ())? = nil) {
        
        guard let orgID = Organization.current?.id else {
            preconditionFailure("Org ID is nil")
        }
        
        var drafts: Set<Event> = Event.readFromFile(path: DRAFTS_PATH.path)[orgID] ?? []
        
        drafts = drafts.filter { $0.uuid != uuid }
        
        if Event.writeToFile(orgID: orgID, events: drafts, path: DRAFTS_PATH.path) {
            handler?(drafts)
        } else {
            print("WARNING: Failed to remove draft \(uuid)!")
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}


// MARK: - Scrolling progress detection

extension EventDraft: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset
        let percentComplete = (point.x - view.frame.size.width) / view.frame.size.width
        transitionProgress = percentComplete
    }
}


// MARK: - Page View Datasource

extension EventDraft: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentPage + 1 == pages.count {
            return nil
        } else {
            return pages[currentPage + 1]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if currentPage == 0 {
            return nil
        } else {
            return pages[currentPage - 1]
        }
    }
}
