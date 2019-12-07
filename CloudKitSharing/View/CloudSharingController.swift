import CloudKit
import SwiftUI

struct CloudSharingController: UIViewControllerRepresentable {
    @EnvironmentObject var store: CloudStore
    @Binding var isShowing: Bool
    
    func makeUIViewController(context: Context) -> CloudControllerHost {
        print("Creating host")
        let host = CloudControllerHost()
        host.rootRecord = store.noteRecord
        host.container = store.container
        return host
    }
    
    func updateUIViewController(_ host: CloudControllerHost, context: Context) {
        print("Updating host: isShowing = \(isShowing)")
        if isShowing, host.isPresented == false {
            print("Presenting host...")
            host.share()
        }
    }
}


final class CloudControllerHost: UIViewController {
    var rootRecord: CKRecord? = nil
    var container: CKContainer = .default()
    var isPresented = false
        
    func share() {
        let sharingController = shareController
        print("Presenting controller")
        isPresented = true
        present(sharingController, animated: true) {
            print("Controller did appear")
        }
    }
    
    lazy var shareController: UICloudSharingController = {
        print("Creating controller")
        let controller = UICloudSharingController { [weak self] controller, completion in
            guard let self = self else { return completion(nil, nil, CloudError.controllerInvalidated) }
            guard let record = self.rootRecord else { return completion(nil, nil, CloudError.missingNoteRecord) }
            
            let share = CKShare(rootRecord: record)
            let operation = CKModifyRecordsOperation(recordsToSave: [record, share], recordIDsToDelete: [])
            operation.modifyRecordsCompletionBlock = { saved, _, error in
                if let error = error {
                    print("Share save error: \(error.localizedDescription)")
                    return completion(nil, nil, error)
                }
                print("Share saved successfully")
                completion(share, self.container, nil)
            }
            print("Saving share...")
            self.container.privateCloudDatabase.add(operation)
        }
        controller.delegate = self
        controller.popoverPresentationController?.sourceView = self.view
        return controller
    }()
}

extension CloudControllerHost: UICloudSharingControllerDelegate {
    func itemTitle(for csc: UICloudSharingController) -> String? {
        "Note Title"
    }
    
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("Share saved")
    }
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("Share failed to save")
    }
    
    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        print("No longer sharing")
    }
}


//extension CloudControllerHost: UIPopoverPresentationControllerDelegate {
//    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
//        print("Popover dismissed")
//        completion?()
//    }
//
//    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
//        print("Attempt to dismiss")
//    }
//
//    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
//        print("Should dismiss")
//        return true
//    }
//
//    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
//        print("Will dismiss")
//    }
//}

//extension CloudSharingController {
//    final class Coordinator: NSObject {
//        let parent: CloudSharingController
//
//        init(parent: CloudSharingController) {
//            self.parent = parent
//        }
//
//    }
//}
//
//extension CloudSharingController.Coordinator: UIPopoverPresentationControllerDelegate {
//    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
//        print("Popover dismissed")
////        completion?()
//    }
//
//    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
//        print("Attempt to dismiss")
//    }
//
//    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
//        print("Should dismiss")
//        return true
//    }
//
//    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
//        print("Will dismiss")
//    }
//}

//final class DismissableCloudController: UICloudSharingController {
//    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        print("Dismissing...")
//        super.dismiss(animated: flag, completion: completion)
//    }
//}


enum CloudError: Error {
    case missingNoteRecord
    case controllerInvalidated
}
